require "socket"
require "resolv"

require "sockit/version"

class SockitError < RuntimeError; end

module Sockit
  DEFAULT_CONFIG = {
    :version => 5,
    :ignore => ["127.0.0.1"],
    :debug => false
  }

  COLORS = {
    :reset => "\e[0m\e[37m",
    :red => "\e[1m\e[31m",
    :green => "\e[1m\e[32m",
    :yellow => "\e[1m\e[33m"
  }

  class << self

    def debug(color, message)
      timestamp = Time.now.utc
      puts("%s%s.%06d %s%s" % [COLORS[color], timestamp.strftime("%Y-%m-%d|%H:%M:%S"), timestamp.usec, message, COLORS[:reset]])
    end

    def dump(action, data)
      bytes = Array.new
      chars = Array.new
      for x in 0..(data.length - 1) do
        bytes << ("%03d" % data[x].ord)
        chars << ("%03s" % (data[x] =~ /^\w+$/ ? data[x].chr : "..."))
      end
      debug(:red, "#{action.to_s.upcase}: #{bytes.join(" ")}#{COLORS[:reset]}")
      debug(:red, "#{action.to_s.upcase}: #{chars.join(" ")}#{COLORS[:reset]}")
    end

    # 0x00 = request granted
    # 0x01 = general failure
    # 0x02 = connection not allowed by ruleset
    # 0x03 = network unreachable
    # 0x04 = host unreachable
    # 0x05 = connection refused by destination host
    # 0x06 = TTL expired
    # 0x07 = command not supported / protocol error
    # 0x08 = address type not supported
    def status_message(status_code)
      case status_code
      when 0x00 then
        "Request granted (Code: 0x%02X)" % status_code
      when 0x01 then
        "General failure (Code: 0x%02X)" % status_code
      when 0x02 then
        "Connection not allowed by ruleset (Code: 0x%02X)" % status_code
      when 0x03 then
        "Network unreachable (Code: 0x%02X)" % status_code
      when 0x04 then
        "Host unreachable (Code: 0x%02X)" % status_code
      when 0x05 then
        "Connection refused by destination host (Code: 0x%02X)" % status_code
      when 0x06 then
        "TTL expired (Code: 0x%02X)" % status_code
      when 0x07 then
        "Command not supported / Protocol error (Code: 0x%02X)" % status_code
      when 0x08 then
        "Address type not supported (Code: 0x%02X)" % status_code
      else
        "Unknown (Code: 0x%02X)" % status_code
      end
    end

    # The authentication methods supported are numbered as follows:
    # 0x00: No authentication
    # 0x01: GSSAPI[10]
    # 0x02: Username/Password[11]
    # 0x03-0x7F: methods assigned by IANA[12]
    # 0x80-0xFE: methods reserved for private use
    def authentication_method(auth_method)
      case auth_method
      when 0x00 then
        "No authentication (Code: 0x%02X)" % auth_method
      when 0x01 then
        "GSSAPI authentication (Code: 0x%02X)" % auth_method
      when 0x02 then
        "Username/Password authentication (Code: 0x%02X)" % auth_method
      when 0x03..0x7F then
        "Method assigned by IANA (Code: 0x%02X)" % auth_method
      when 0x80..0xFE then
        "Method reserved for private use (Code: 0x%02X)" % auth_method
      when 0xFF then
        "Unsupported (Code: 0x%02X)" % auth_method
      else
        "Unknown (Code: 0x%02X)" % auth_method
      end
    end

    # 0x00 = success
    # any other value = failure, connection must be closed
    def authentication_status(auth_status)
      case auth_status
      when 0x00 then
        "Authentication success (Code: 0x%02X)" % auth_status
      else
        "Authentication failure (Code: 0x%02X)" % auth_status
      end
    end

  end
end

class TCPSocket

  class << self

    def socks(&block)
      @@socks ||= OpenStruct.new(Sockit::DEFAULT_CONFIG)
      if block_given?
        yield(@@socks)
      else
        @@socks
      end
    end

  end

  def socks(&block)
    @@socks ||= OpenStruct.new(Sockit::DEFAULT_CONFIG)
    if block_given?
      yield(@@socks)
    else
      @@socks
    end
  end

  alias :initialize_tcp :initialize
  def initialize(remote_host, remote_port, local_host=nil, local_port=nil)
    if (socks.host && socks.port && !socks.ignore.flatten.include?(remote_host))
      Sockit.debug(:yellow, "Connecting to SOCKS server #{socks.host}:#{socks.port}")
      initialize_tcp(socks.host, socks.port)
      (socks.version.to_i == 5) and socks_authenticate
      socks.host and socks_connect(remote_host, remote_port)
      Sockit.debug(:green, "Connected to #{remote_host}:#{remote_port} via SOCKS server #{socks.host}:#{socks.port}")
    else
      Sockit.debug(:yellow, "Directly connecting to #{remote_host}:#{remote_port}")
      initialize_tcp(remote_host, remote_port, local_host, local_port)
      Sockit.debug(:green, "Connected to #{remote_host}:#{remote_port}")
    end
  end

  def socks_authenticate
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
    if (socks.username || socks.password)
      data = Array.new
      data << [socks.version, 0x02, 0x02, 0x00].pack("C*")
      data = data.flatten.join

      socks.debug and Sockit.debug(:yellow, "Requesting username/password authentication")
      socks.debug and Sockit.dump(:write, data)
      write(data)
    else
      data = Array.new
      data << [socks.version, 0x01, 0x00].pack("C*")
      data = data.flatten.join

      socks.debug and Sockit.debug(:yellow, "Requesting no authentication")
      socks.debug and Sockit.dump(:write, data)
      write(data)
    end

    # The server's choice is communicated:
    # field 1: SOCKS version, 1 byte (0x05 for this version)
    # field 2: chosen authentication method, 1 byte, or 0xFF if no acceptable methods were offered
    socks.debug and Sockit.debug(:yellow, "Waiting for SOCKS authentication reply")
    auth_reply = recv(2).unpack("C*")
    socks.debug and Sockit.dump(:read, auth_reply)
    server_socks_version = auth_reply[0]
    server_auth_method = auth_reply[1]

    if server_socks_version != socks.version
      raise SockitError, "SOCKS server does not support version #{socks.version}!"
    end

    if server_auth_method == 0xFF
      raise SockitError, Sockit.authentication_method(server_auth_method)
    else
      socks.debug and Sockit.debug(:green, Sockit.authentication_method(server_auth_method))
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

      socks.debug and Sockit.debug(:yellow, "Sending username and password")
      socks.debug and Sockit.dump(:write, data)
      write(data)

      # Server response for username/password authentication:
      # field 1: version, 1 byte
      # field 2: status code, 1 byte.
      # 0x00 = success
      # any other value = failure, connection must be closed
      socks.debug and Sockit.debug(:yellow, "Waiting for SOCKS authentication reply")
      auth_reply = recv(2).unpack("C*")
      socks.debug and Sockit.dump(:read, auth_reply)
      version = auth_reply[0]
      status_code = auth_reply[1]

      if status_code == 0x00
        socks.debug and Sockit.debug(:green, Sockit.authentication_status(status_code))
      else
        raise SockitError, Sockit.authentication_status(status_code)
      end
    end

  end

  def socks_connect(remote_host, remote_port)
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
    data << [ socks.version.to_i, 0x01, 0x00 ].pack("C*")

    # when doing proxy mode on SS5; we seemingly need to resolve all names first.
    if remote_host !~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
      remote_host = Resolv::DNS.new.getaddress(remote_host).to_s
    end

    if remote_host =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
      data << [0x01].pack("C*")
      data << [$1.to_i, $2.to_i, $3.to_i, $4.to_i].pack("C*")
    elsif remote_host =~ /^[:0-9a-f]+$/
      data << [0x04].pack("C*")
      data << [$1].pack("C*")
    else
      data << [0x03].pack("C*")
      data << [remote_host.length.to_i].pack("C*")
      data << remote_host
    end
    data << [remote_port].pack("n")
    data = data.flatten.join

    Sockit.debug(:yellow, "Requesting SOCKS connection to #{remote_host}:#{remote_port}")
    socks.debug and Sockit.dump(:write, data)
    write(data)

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
    socks.debug and Sockit.debug(:yellow, "Waiting for SOCKS connection reply")
    packet = recv(4).unpack("C*")
    socks.debug and Sockit.dump(:read, packet)
    socks_version = packet[0]
    status_code = packet[1]
    reserved = packet[2]
    address_type = packet[3]

    if status_code == 0x00
      socks.debug and Sockit.debug(:green, Sockit.status_message(status_code))
    else
      raise SockitError, Sockit.status_message(status_code)
    end

    address_length = case address_type
    when 0x01 then
      4
    when 0x03 then
      data = recv(1).unpack("C*")
      socks.debug and Sockit.dump(:read, data)
      data[0]
    when 0x04 then
      16
    end
    address = recv(address_length).unpack("C*")
    socks.debug and Sockit.dump(:read, address)

    port = recv(2).unpack("n")
    socks.debug and Sockit.dump(:read, port)

    socks.debug and Sockit.debug(:green, [address, port].inspect)
  end

end
