# A sample frontend app built on top of Ruby and Sinatra. It returns HTML.

require 'sinatra'
require 'open-uri'

if ARGV.length != 3
  raise 'Expected exactly three arguments: SERVER_PORT SERVER_TEXT BACKEND_URL'
end

server_port = ARGV[0]
server_text = ARGV[1]
backend_url = ARGV[2]

set :port, server_port
set :bind, '0.0.0.0'

get '/' do
  content_type :html
  open(backend_url) do |content|
    "<h1>#{server_text}</h1><p>Response from backend:</p><pre>#{content.read.to_s}</pre>"
  end
end
