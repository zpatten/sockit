module Sockit
  module Connection

    def direct_connect(socket, remote_host, remote_port, local_host=nil, local_port=nil)
      log(:yellow, "Directly connecting to #{remote_host}:#{remote_port}")
      socket.__send__(:initialize_tcp, remote_host, remote_port, local_host=nil, local_port=nil)
      log(:green, "Connected to #{remote_host}:#{remote_port}")
    end

    def connect(socket, host, port)
      log(:yellow, "Connecting to SOCKS v#{config.version} server #{config.host}:#{config.port}")

      # when doing proxy mode on SS5; we seemingly need to resolve all names first.
      if host !~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
        host = Resolv::DNS.new.getaddress(host).to_s
      end

      data = case config.version.to_i
      when 4 then
        build_v4_connection_request(host, port)
      when 5 then
        build_v5_connection_request(host, port)
      end
      data = data.flatten.join

      log(:yellow, "Requesting SOCKS v#{config.version} connection to #{host}:#{port}")
      dump(:write, data)
      socket.write(data)

      log(:yellow, "Waiting for SOCKS v#{config.version} connection reply")
      host, port = case config.version.to_i
      when 4 then
        process_v4_connection_response(socket)
      when 5 then
        process_v5_connection_response(socket)
      end
      log(:green, [host, port].inspect)

      log(:green, "Connected to #{host}:#{port} via SOCKS v#{config.version} server #{config.host}:#{config.port}")
    end

  end
end
