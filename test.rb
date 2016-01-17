require 'sockit'
TCPSocket.socks do |socks|
  socks.version = 5
  socks.debug = true
  socks.host = "127.0.0.1"
  socks.port = "1080"
end
socket = TCPSocket.new('www.google.com', '80')
puts socket.read_nonblock(4096).inspect rescue nil
