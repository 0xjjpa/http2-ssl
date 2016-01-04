#!/bin/bash

curl ifconfig.io | xargs sh -c 'aws ec2 authorize-security-group-ingress --group-name default --protocol tcp --port 22 --cidr $0/32'
