module Sockit
  module Support

    def is_host_configured?
      (!config.host.nil? && !config.host.empty?)
    end

    def is_port_configured?
      (!config.port.nil? && !config.port.empty?)
    end

    def is_version_configured?
      ((config.version == 4) || (config.version == 5))
    end

    def is_configured?
      (is_host_configured? && is_port_configured? && is_version_configured?)
    end

    def connect_via_socks?(host)
      (is_configured? && !config.ignore.flatten.any?{ |ignored_host| host =~ /#{ignored_host}/ })
    end

    def is_socks_v5?
      (is_configured? && config.version.to_i == 5)
    end

    def is_socks_v4?
      (is_configured? && config.version.to_i == 4)
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

  end
end
