#!/bin/bash
# Install and configure a sample backend app built on top of Ruby and Sinatra

set -e

readonly APP_RB_SRC="/tmp/app.rb"
readonly APP_RB_DST="/home/ubuntu/app.rb"

echo "Installing Ruby"
sudo apt-get update
sudo apt-get install -y make zlib1g-dev build-essential ruby ruby-dev

echo "Installing Sinatra"
sudo gem install sinatra json --no-rdoc --no-ri

echo "Moving $APP_RB_SRC to $APP_RB_DST"
mv "$APP_RB_SRC" "$APP_RB_DST"