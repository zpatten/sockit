module Sockit
  module Support

    def configured?
      (config.host && config.port && config.version)
    end

    def connect_via_socks?(host)
      (configured? && !config.ignore.flatten.include?(host))
    end

    def log(color, message)
      return if !config.debug

      timestamp = Time.now.utc
      puts("%s%s.%06d %s%s" % [COLORS[color], timestamp.strftime("%Y-%m-%d|%H:%M:%S"), timestamp.usec, message, COLORS[:reset]])
    end

    def dump(action, data)
      return if !config.debug

      bytes = Array.new
      chars = Array.new
      for x in 0..(data.length - 1) do
        bytes << ("%03d" % data[x].ord)
        chars << ("%03s" % (data[x] =~ /^\w+$/ ? data[x].chr : "..."))
      end
      log(:blue, "#{action.to_s.upcase}: #{bytes.join(" ")}#{COLORS[:reset]}")
      log(:blue, "#{action.to_s.upcase}: #{chars.join(" ")}#{COLORS[:reset]}")
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

    rescue
      "Status Code: #{status_code.inspect}"
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
        "Authentication method assigned by IANA (Code: 0x%02X)" % auth_method
      when 0x80..0xFE then
        "Authentication method reserved for private use (Code: 0x%02X)" % auth_method
      when 0xFF then
        "Unsupported authentication (Code: 0x%02X)" % auth_method
      else
        "Unknown authentication (Code: 0x%02X)" % auth_method
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
