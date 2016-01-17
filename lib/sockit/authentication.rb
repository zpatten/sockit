module Sockit
  module Authentication

    def authenticate(socket)
      log(:yellow, "Authenticating with SOCKS server #{config.host}:#{config.port}")

      # The authentication methods supported are numbered as follows:
      # 0x00: No authentication
      # 0x01: GSSAPI[10]
      # 0x02: Username/Password[11]
      # 0x03-0x7F: methods assigned by IANA[12]
      # 0x80-0xFE: methods reserved for private use

      # The initial greeting from the client is
      # field 1: SOCKS version number (must be 0x05 for this version)
      # field 2: number of authentication methods supported, 1 byte
      # field 3: authentication methods, variable length, 1 byte per method supported
      if (config.username || config.password)
        data = Array.new
        data << [config.version, 0x02, 0x02, 0x00].pack("C*")
        data = data.flatten.join

        log(:yellow, "Requesting username/password authentication")
        dump(:write, data)
        socket.write(data)
      else
        data = Array.new
        data << [config.version, 0x01, 0x00].pack("C*")
        data = data.flatten.join

        log(:yellow, "Requesting no authentication")
        dump(:write, data)
        socket.write(data)
      end

      # The server's choice is communicated:
      # field 1: SOCKS version, 1 byte (0x05 for this version)
      # field 2: chosen authentication method, 1 byte, or 0xFF if no acceptable methods were offered
      log(:yellow, "Waiting for SOCKS authentication reply")
      auth_reply = socket.recv(2).unpack("C*")
      dump(:read, auth_reply)
      server_socks_version = auth_reply[0]
      server_auth_method = auth_reply[1]

      if server_socks_version != config.version
        raise SockitError, "SOCKS server does not support version #{config.version}!"
      end

      if server_auth_method == 0xFF
        raise SockitError, authentication_method(server_auth_method)
      else
        log(:green, authentication_method(server_auth_method))
      end

      # The subsequent authentication is method-dependent. Username and password authentication (method 0x02) is described in RFC 1929:
      case server_auth_method
      when 0x00 then
        # No authentication
      when 0x01 then
        # GSSAPI
        raise SockitError, "Authentication method GSSAPI not implemented"
      when 0x02 then
        # For username/password authentication the client's authentication request is
        # field 1: version number, 1 byte (must be 0x01)
        # field 2: username length, 1 byte
        # field 3: username
        # field 4: password length, 1 byte
        # field 5: password
        data = Array.new
        data << [0x01].pack("C*")
        data << [socks.username.length.to_i].pack("C*")
        data << socks.username
        data << [socks.password.length.to_i].pack("C*")
        data << socks.password
        data = data.flatten.join

        log(:yellow, "Sending username and password")
        dump(:write, data)
        socket.write(data)

        # Server response for username/password authentication:
        # field 1: version, 1 byte
        # field 2: status code, 1 byte.
        # 0x00 = success
        # any other value = failure, connection must be closed
        log(:yellow, "Waiting for SOCKS authentication reply")
        auth_reply = socket.recv(2).unpack("C*")
        dump(:read, auth_reply)
        version = auth_reply[0]
        status_code = auth_reply[1]

        if status_code == 0x00
          log(:green, authentication_status(status_code))
        else
          raise SockitError, authentication_status(status_code)
        end
      end

      log(:green, "Authenticated to SOCKS server #{config.host}:#{config.port}")
    end

  end
end
