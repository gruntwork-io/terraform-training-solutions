# A sample backend app built on top of Ruby and Sinatra. It returns JSON.

require 'sinatra'
require 'json'

if ARGV.length != 2
  raise 'Expected exactly two arguments: SERVER_PORT SERVER_TEXT'
end

server_port = ARGV[0]
server_text = ARGV[1]

set :port, server_port
set :bind, '0.0.0.0'

get '/' do
  content_type :json
  {:text => server_text}.to_json
end
