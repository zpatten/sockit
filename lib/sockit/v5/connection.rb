module Sockit
  module V5
    module Connection

      # SOCKS v5 Client Connection Request
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
      def build_v5_connection_request(host, port)
        data = Array.new
        data << [config.version.to_i, 0x01, 0x00].pack("C*")

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

        data
      end

      # SOCKS v5 Server Connection Response
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
      def process_v5_connection_response(socket)
        packet = socket.recv(4).unpack("C*")
        dump(:read, packet)
        socks_version = packet[0]
        result_code = packet[1]
        reserved = packet[2]
        address_type = packet[3]

        if result_code == 0x00
          log(:green, build_v5_result_code_message(result_code))
        else
          raise SockitError, build_v5_result_code_message(result_code)
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
        host = socket.recv(address_length).unpack("C*")
        dump(:read, host)

        port = socket.recv(2).unpack("n")
        dump(:read, port)

        [host.join('.'), port.join]
      end

    end
  end
end
