#!powershell
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# WANT_JSON
# POWERSHELL_COMMON

$params = Parse-Args $args;

$name = Get-Attr $params "name" $FALSE;
If ($name -eq $FALSE)
{
    Fail-Json (New-Object psobject) "missing required argument: name";
}

$install = Get-Attr $params "install" $FALSE
$uninstall = Get-Attr $params "uninstall" $FALSE
$dest = Get-Attr $params "dest" $FALSE
$args = Get-Attr $params "args" $FALSE


$result = New-Object psobject @{
    win_product = New-Object psobject
    changed = $false
};

$obj = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "$name" }
$obj_by_name = Get-WmiObject -Class Win32_Product | Select-Object -property Name | where { $_.Name -eq "$name" }


If ($obj_by_name) {
   If ($install -eq "true") {
      Set-Attr $result.win_product "already installed" $name;
   }  
   ElseIf ($uninstall -eq "true") {
      $obj.Uninstall()
   }
   Else {
      $result.stdout = "$name";
   }
}
Else {
   If ($install -eq "true") {
       If (Test-Path $dest) {
	   $result.stdout = "Starting";
           $product = [WMICLASS]"\\$env:computername\ROOT\CIMV2:win32_Product"
	   If ( "$args" -ne $FALSE ) {
		   $retrun_obj = $product.Install("$dest","$args")
	   }
	   Else {
		   $retrun_obj = $product.Install("$dest")
	   }
	   If ( $retrun_obj.Properties.value -ne 0 ) {
		$result.stdout = "Failed to install $name - ErrorCode: $retrun_obj.Properties.value";
	   }
	   Else {
	        $result.stdout = "$name installed successfully";
	   }
       }
       Else {
           Fail-Json $result "$dest : not exist"
       }  
   } 
   ElseIf ($uninstall -eq "true") {
      Set-Attr $result.win_product "$name is not installed" $name;
   } 
   Else {
      $result.stdout = "";
   }
}

Set-Attr $result "changed" $true;
Exit-Json $result;
