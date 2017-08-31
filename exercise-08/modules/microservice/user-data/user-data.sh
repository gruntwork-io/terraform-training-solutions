#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. It expects to be running on
# an AMI built with the Packer template in exercise-07/packer/frontend/frontend.json. It starts a simple Sinatra app as
# a sample frontend service.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Run the frontend app
nohup ruby /home/ubuntu/app.rb "${server_http_port}" "${server_text}"${backend_url == "" ? "" : " ${backend_url}"} &
