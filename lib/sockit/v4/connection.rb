module Sockit
  module V4
    module Connection

      # SOCKS v4 Client Connection Request
      # field 1: SOCKS version number, 1 byte (must be 0x04 for this version)
      # field 2: command code, 1 byte:
      # 0x01 = establish a TCP/IP stream connection
      # field 3: port number in a network byte order, 2 bytes
      # field 4: destination address of
      # 4 bytes for IPv4 address
      # field 5: userid
      # variables bytes for userid, null terminate (0x00)
      def build_v4_connection_request(host, port)
        data = Array.new
        data << [config.version.to_i, 0x01].pack("C*")

        data << [port.to_i].pack("n")
        if host =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
          data << [$1.to_i, $2.to_i, $3.to_i, $4.to_i].pack("C*")
        end
        data << config.username
        data << [0x00].pack("C*")

        data
      end

      # SOCKS v4 Server Connection Response
      # field 1: version number, 1 byte (must be 0x00)
      # field 2: result code, 1 byte:
      # 90 = request granted
      # 91 = request rejected or failed
      # 92 = request rejected because SOCKS server can not connect to identd on the client
      # 93 = request rejected because the client program and identd report different user-ids
      # field 3: port number in a network byte order, 2 bytes
      # field 4: destination address of
      # 4 bytes for IPv4 address
      def process_v4_connection_response(socket)
        packet = socket.recv(2).unpack("C*")
        dump(:read, packet)
        version = packet[0]
        result_code = packet[1]

        case result_code
        when 90 then
          log(:green, build_v4_result_code_message(result_code))
        else
          raise SockitError, build_v4_result_code_message(result_code)
        end

        port = socket.recv(2).unpack("n")
        dump(:read, port)

        host = socket.recv(4).unpack("C*")
        dump(:read, host)

        [host.join('.'), port.join]
      end

    end
  end
end
