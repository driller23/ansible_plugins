#!/usr/bin/python

DOCUMENTATION = '''
---
module: azlist
short_description: Retrieve information about availabilty Zones in Region
description:
  - Retrieve information about all Availabilty Zones in Region
author: Igal Dahan
requirements:
  - Requires the Boto and Boto3 module
options:
  region:
    description:
      - The AWS region to use.
    required: False
    default: null
    aliases: [ 'aws_region', 'ec2_region' ]
  aws_secret_key:
    description:
      - AWS secret key. If not set then the value of
        the AWS_SECRET_KEY environment variable is used.
    required: false
    default: null
    aliases: [ 'ec2_secret_key', 'secret_key' ]
  aws_access_key:
    description:
      - AWS access key. If not set then the value of the
        AWS_ACCESS_KEY environment variable is used.
    required: false
    default: null
    aliases: [ 'ec2_access_key', 'access_key' ]
extends_documentation_fragment: aws

'''

EXAMPLES = '''

  - name: get route53 info
    azlist: zone_name="example.org." region="eu-west-1"
    register: zone_info

  - debug: var=zone_info

'''

try:
   import boto
   import boto3
except ImportError:
    print "failed=True msg='boto required for this module'"
    exit(1)


def main():
    argument_spec = ec2_argument_spec()

    module = AnsibleModule(
        argument_spec=argument_spec,
    )

    aws_secret_key = module.params.get('aws_secret_key')
    aws_access_key = module.params.get('aws_access_key')
    region = module.params['region']

    client = boto3.client('ec2',region_name=region)
     
    azones = []
    for zone in client.describe_availability_zones()["AvailabilityZones"]:
        print zone['ZoneName']
        azones.append(zone['ZoneName'])

    module.exit_json(changed=False,zones=azones)


# import module snippets
from ansible.module_utils.basic import *
from ansible.module_utils.ec2 import *

main()
