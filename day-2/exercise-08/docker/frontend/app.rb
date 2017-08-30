# A sample frontend app built on top of Ruby and Sinatra. It returns HTML.

require 'sinatra'
require 'open-uri'

server_port = ENV['SERVER_PORT'] || 8080
server_text = ENV['SERVER_TEXT'] || "Hello from frontend"

# This strangely-named environment variable will be set by docker-compose in dev (due to the use of links) and by
# Terraform in prod (see the container definition)
backend_addr = ENV['BACKEND_PORT_8081_TCP_ADDR'] || 'localhost'
backend_url = "http://#{backend_addr}:8081"

set :port, server_port
set :bind, '0.0.0.0'

get '/' do
  content_type :html
  open(backend_url) do |content|
    "<h1>#{server_text}</h1><p>Response from backend:</p><pre>#{content.read.to_s}</pre>"
  end
end
