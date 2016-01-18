module Sockit
  module V4
    module Support

      # 90 = request granted
      # 91 = request rejected or failed
      # 92 = request rejected because SOCKS server can not connect to identd on the client
      # 93 = request rejected because the client program and identd report different user-ids
      def build_v4_result_code_message(result_code)
        message = case result_code
        when 90 then
          "Request granted"
        when 91 then
          "Request rejected or failed"
        when 92 then
          "Request rejected because SOCKS server can not connect to identd on the client"
        when 93 then
          "Request rejected because the client program and identd report different user-ids"
        else
          "Unknown"
        end

        "%s (Code: 0x%02X)" % [message, result_code]

      rescue
        "Result Code: #{result_code.inspect}"
      end

    end
  end
end
