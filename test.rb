require 'bundler/setup'
require 'sockit'

Sockit.config do |config|
  config.version = 5
  config.debug = true
  config.host = "127.0.0.1"
  config.port = "1080"
end

socket = TCPSocket.new('www.google.com', '80')
puts socket.read.inspect
