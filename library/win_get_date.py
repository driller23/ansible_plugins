DOCUMENTATION = '''
---
module: win_get_date
version_added: "0.1"
short_description: Call Get-Host cmdlet.
description:
- Call Get-Host cmdlet
'''
EXAMPLES = '''
# Test connectivity to a windows host
ansible winserver -m get_host
# Example from an Ansible Playbook
- action: win_get_date
'''


