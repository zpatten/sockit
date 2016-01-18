module Sockit
  module V5
    module Support

      # 0x00 = request granted
      # 0x01 = general failure
      # 0x02 = connection not allowed by ruleset
      # 0x03 = network unreachable
      # 0x04 = host unreachable
      # 0x05 = connection refused by destination host
      # 0x06 = TTL expired
      # 0x07 = command not supported / protocol error
      # 0x08 = address type not supported
      def build_v5_result_code_message(result_code)
        message = case result_code
        when 0x00 then
          "Request granted"
        when 0x01 then
          "General failure"
        when 0x02 then
          "Connection not allowed by ruleset"
        when 0x03 then
          "Network unreachable"
        when 0x04 then
          "Host unreachable"
        when 0x05 then
          "Connection refused by destination host"
        when 0x06 then
          "TTL expired"
        when 0x07 then
          "Command not supported / Protocol error"
        when 0x08 then
          "Address type not supported"
        else
          "Unknown"
        end

        "%s (Code: 0x%02X)" % [message, result_code]

      rescue
        "Result Code: #{result_code.inspect}"
      end

      # The authentication methods supported are numbered as follows:
      # 0x00: No authentication
      # 0x01: GSSAPI[10]
      # 0x02: Username/Password[11]
      # 0x03-0x7F: methods assigned by IANA[12]
      # 0x80-0xFE: methods reserved for private use
      def build_v5_authentication_method_message(auth_method)
        message = case auth_method
        when 0x00 then
          "No authentication"
        when 0x01 then
          "GSSAPI authentication"
        when 0x02 then
          "Username/Password authentication"
        when 0x03..0x7F then
          "Authentication method assigned by IANA"
        when 0x80..0xFE then
          "Authentication method reserved for private use"
        when 0xFF then
          "Unsupported authentication"
        else
          "Unknown authentication"
        end

        "%s (Method: 0x%02X)" % [message, auth_method]

      rescue
        "Authentication Method: #{auth_method.inspect}"
      end

      # 0x00 = success
      # any other value = failure, connection must be closed
      def build_v5_authentication_status_message(auth_status)
        message = case auth_status
        when 0x00 then
          "Authentication success"
        else
          "Authentication failure"
        end

        "%s (Status: 0x%02X)" % [message, auth_status]

      rescue
        "Authentication Status: #{auth_status.inspect}"
      end

    end
  end
end
