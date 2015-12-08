#!powershell
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

$src= Get-Attr $params "src" $FALSE;
If ($src -eq $FALSE)
{
    Fail-Json (New-Object psobject) "missing required argument: src";
}

$dest= Get-Attr $params "dest" $FALSE;
If ($dest -eq $FALSE)
{
    Fail-Json (New-Object psobject) "missing required argument: dest";
}

#$state = Get-Attr $params "state" "unspecified"

$result = New-Object psobject @{
    changed = $FALSE
};

If ( -Not (Test-Path $src))
{
   Fail-Json (New-Object psobject) "Source $src does not exist";
}

If (Test-Path $dest)
{
  If ((Get-Item $dest).Attributes -eq "Directory") 
    {
        If ((Get-Item $src).Attributes -eq "Directory")
        {
            Move-Item -Path $src -Destination $dest -Force;
        }
        ElseIf ((Get-Item $src).Attributes -eq "File")
        {
            Move-Item -Path $src -Destination $dest -Force;
        }
    }   

  Else #((Get-Item $dest).Attributes -eq "File") 
  {
        If ((Get-Item $src).Attributes -eq "Directory")
        {
            Fail-Json (New-Object psobject) "Cannot move Directory into File";
        }
        Else
        {
            $dest_md5 = (Get-FileHash -Path $dest -Algorithm MD5).Hash.ToLower();
            $src_md5 = (Get-FileHash -Path $src -Algorithm MD5).Hash.ToLower();

            If ( $src_md5 -ne $dest_md5)
            {
               Move-Item -Path $src -Destination $dest -Force;
            }

            $dest_md5 = (Get-FileHash -Path $dest -Algorithm MD5).Hash.ToLower();
            If ( $src_md5 -eq $dest_md5)
            {
               $result.changed = $TRUE;
            }   
            Else
            {   
               Fail-Json (New-Object psobject) "Failed to place file";
            }
        }
    }
}
Else
{
    Fail-Json (New-Object psobject) "destination: $dest does not exist";
}
Exit-Json $result;
