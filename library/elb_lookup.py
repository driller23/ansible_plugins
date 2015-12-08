#!/usr/bin/env python

EXAMPLES = '''
# Return all Load Balancer named that match the tag "Environment = Production"
- local_action:
    module: elb_lookup
    tags:
        Environment: "Production"


# Work with YML file:

# Work from Locahost machine
- hosts: localhost
  connection: local
  # Load all env varibles (Such as AWS secert key + region + ...)
  vars_files:
    - "ansible/group_vars/all"
  tasks:
  - name: lookup elb by tags
    local_action:
      module: elb_lookup
      region: "us-east-1"
      # the wanted tags:
      tags:
         - Environment: "Production"
         - App: "GUI"
    # Save output to elb varible:
    register: ec2

'''




import boto3
import boto.ec2.elb
from ansible.module_utils.basic import *


def main():
	module=AnsibleModule(
	    argument_spec=dict(
		region=dict(aliases=['aws_region', 'ec2_region'] ),
		aws_secret_key=dict(aliases=['ec2_secret_key', 'secret_key'],
				    no_log=True),
		aws_access_key=dict(aliases=['ec2_access_key', 'access_key']),
		tags=dict(default=None),
	    )
	)

	tags_param = module.params.get('tags')
	tags = {}
	if isinstance(tags_param, list):
	  for item in module.params.get('tags'):
	      for k,v in item.iteritems():
		  tags[k] = v
	elif isinstance(tags_param, dict):
	    tags = tags_param
	else:
	    module.fail_json(msg="Invalid format for tags")


	aws_secret_key = module.params.get('aws_secret_key')
	aws_access_key = module.params.get('aws_access_key')
	region = module.params.get('region')

	input_tags = []
	for i in tags:
		tag_dict = {}
		tag_dict['Key'] = i
		tag_dict['Value'] = tags[i]
		input_tags.append(tag_dict)


	client = boto3.client('elb', region_name=region)
	conn = boto.ec2.elb.connect_to_region(region)
	elb_list = conn.get_all_load_balancers()


	i=0
	elb_names = []
	elbs_desc = []
	elbs = []


	for elb in elb_list:
		elb_names.append(elb.name)
		i += 1
		if i <= 20:
			if i == 20:
				i = 0
			elbs_desc.append(client.describe_tags(LoadBalancerNames=elb_names))
			elb_names=[]
#			i = 1

	for elb_tags in elbs_desc:
		for elb in elb_tags['TagDescriptions']:
			#print elb['LoadBalancerName']
			matches = 0
			for tag in elb['Tags']:
				for input_tag in input_tags:
					if tag['Key'] == input_tag['Key'] and tag['Value'] == input_tag['Value']:
						matches += 1
			if matches == len(input_tags):
				elbs.append( elb['LoadBalancerName'] )

	module.exit_json(changed=False, elbs=elbs)

main()

