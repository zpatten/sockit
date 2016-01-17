module Sockit
  module Connect

    def direct_connect(socket, remote_host, remote_port, local_host=nil, local_port=nil)
      log(:yellow, "Directly connecting to #{remote_host}:#{remote_port}")
      socket.initialize_tcp(remote_host, remote_port, local_host, local_port)
      log(:green, "Connected to #{remote_host}:#{remote_port}")
    end

    def connect(socket, host, port)
      log(:yellow, "Connecting to SOCKS server #{config.host}:#{config.port}")

      # The client's connection request is
      # field 1: SOCKS version number, 1 byte (must be 0x05 for this version)
      # field 2: command code, 1 byte:
      # 0x01 = establish a TCP/IP stream connection
      # 0x02 = establish a TCP/IP port binding
      # 0x03 = associate a UDP port
      # field 3: reserved, must be 0x00
      # field 4: address type, 1 byte:
      # 0x01 = IPv4 address
      # 0x03 = Domain name
      # 0x04 = IPv6 address
      # field 5: destination address of
      # 4 bytes for IPv4 address
      # 1 byte of name length followed by the name for Domain name
      # 16 bytes for IPv6 address
      # field 6: port number in a network byte order, 2 bytes
      data = Array.new
      data << [ config.version.to_i, 0x01, 0x00 ].pack("C*")

      # when doing proxy mode on SS5; we seemingly need to resolve all names first.
      if host !~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
        host = Resolv::DNS.new.getaddress(host).to_s
      end

      if host =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
        data << [0x01].pack("C*")
        data << [$1.to_i, $2.to_i, $3.to_i, $4.to_i].pack("C*")
      elsif host =~ /^[:0-9a-f]+$/
        data << [0x04].pack("C*")
        data << [$1].pack("C*")
      else
        data << [0x03].pack("C*")
        data << [host.length.to_i].pack("C*")
        data << host
      end
      data << [port.to_i].pack("n")
      data = data.flatten.join

      log(:yellow, "Requesting SOCKS connection to #{host}:#{port}")
      dump(:write, data)
      socket.write(data)

      # Server response:
      # field 1: SOCKS protocol version, 1 byte (0x05 for this version)
      # field 2: status, 1 byte:
      # 0x00 = request granted
      # 0x01 = general failure
      # 0x02 = connection not allowed by ruleset
      # 0x03 = network unreachable
      # 0x04 = host unreachable
      # 0x05 = connection refused by destination host
      # 0x06 = TTL expired
      # 0x07 = command not supported / protocol error
      # 0x08 = address type not supported
      # field 3: reserved, must be 0x00
      # field 4: address type, 1 byte:
      # 0x01 = IPv4 address
      # 0x03 = Domain name
      # 0x04 = IPv6 address
      # field 5: destination address of
      # 4 bytes for IPv4 address
      # 1 byte of name length followed by the name for Domain name
      # 16 bytes for IPv6 address
      # field 6: network byte order port number, 2 bytes
      log(:yellow, "Waiting for SOCKS connection reply")
      packet = socket.recv(4).unpack("C*")
      dump(:read, packet)
      socks_version = packet[0]
      status_code = packet[1]
      reserved = packet[2]
      address_type = packet[3]

      if status_code == 0x00
        log(:green, status_message(status_code))
      else
        raise SockitError, status_message(status_code)
      end

      address_length = case address_type
      when 0x01 then
        4
      when 0x03 then
        data = socket.recv(1).unpack("C*")
        dump(:read, data)
        data[0]
      when 0x04 then
        16
      end
      address = socket.recv(address_length).unpack("C*")
      dump(:read, address)

      port = socket.recv(2).unpack("n")
      dump(:read, port)

      log(:green, [address, port].inspect)

      log(:green, "Connected to #{host}:#{port} via SOCKS server #{config.host}:#{config.port}")
    end

  end
end
