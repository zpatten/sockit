################################################################################
#
#      Author: Zachary Patten <zpatten AT jovelabs DOT io>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################

require 'socket'
require 'resolv'
require 'ostruct'

require 'sockit/version'

require 'sockit/v4/connection'
require 'sockit/v4/support'

require 'sockit/v5/authentication'
require 'sockit/v5/connection'
require 'sockit/v5/support'

require 'sockit/connection'
require 'sockit/support'

class SockitError < RuntimeError; end

module Sockit
  DEFAULT_CONFIG = {
    :version => 5,
    :ignore  => %w( 127.0.0.1 ),
    :debug   => false
  }

  COLORS = {
    :reset  => "\e[0m\e[37m",
    :red    => "\e[1m\e[31m",
    :green  => "\e[1m\e[32m",
    :yellow => "\e[1m\e[33m",
    :blue   => "\e[1m\e[34m"
  }

  def self.config(&block)
    @@config ||= OpenStruct.new(Sockit::DEFAULT_CONFIG)
    if block_given?
      yield(@@config)
    else
      @@config
    end
  end

  def config(&block)
    @@config ||= OpenStruct.new(Sockit::DEFAULT_CONFIG)
    if block_given?
      yield(@@config)
    else
      @@config
    end
  end

  def self.enabled?
    @@enabled ||= false
  end

  def self.enable
    @@enabled = true
  end

  def self.disable
    @@enabled = false
  end

  extend Sockit::V5::Authentication
  extend Sockit::V5::Connection
  extend Sockit::V5::Support

  extend Sockit::V4::Connection
  extend Sockit::V4::Support

  extend Sockit::Connection
  extend Sockit::Support
end

class TCPSocket

  alias :initialize_tcp :initialize

  def initialize(remote_host, remote_port, local_host=nil, local_port=nil)
    if Sockit.enabled? && Sockit.connect_via_socks?(Sockit.resolve(remote_host))
      initialize_tcp(Sockit.config.host, Sockit.config.port)
      Sockit.perform_v5_authenticate(self) if Sockit.is_socks_v5?
      Sockit.connect(self, remote_host, remote_port)
    else
      Sockit.direct_connect(self, remote_host, remote_port, local_host, local_port)
    end
  end

end
