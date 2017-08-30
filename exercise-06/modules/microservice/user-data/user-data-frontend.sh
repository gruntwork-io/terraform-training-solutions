#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. It starts a simple
# "Hello, World" web server that acts like a frontend service that returns HTML.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Since we need to make some live HTTP calls for the frontend, a simple one-liner static HTTP server won't do. Instead,
# we do a hacky install of Sinatra here and use that to proxy requests
sudo apt-get install -y ruby
sudo gem install sinatra --no-rdoc --no-ri

# Create the Sinatra app. The variables below are filled via Terraform interpolation.
cat << EOF > app.rb
require 'sinatra'
require 'open-uri'

set :port, ${server_http_port}
set :bind, '0.0.0.0'

get '/' do
  open('${backend_url}') do |content|
    "<h1>${server_text}</h1><p>Response from backend:</p><pre>" + content.read.to_s + "</pre>"
  end
end
EOF

# Run the Sinatra app.
nohup ruby app.rb &
