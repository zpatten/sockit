################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
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
require 'sockit/authentication'
require 'sockit/connect'
require 'sockit/support'

class SockitError < RuntimeError; end

module Sockit
  DEFAULT_CONFIG = {
    :version => 5,
    :ignore  => %w( 127.0.0.1 ),
    :debug   => false,
    :host    => "127.0.0.1",
    :port    => "1080"
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

  extend Sockit::Authentication
  extend Sockit::Connect
  extend Sockit::Support
end

class TCPSocket

  alias :initialize_tcp :initialize
  def initialize(remote_host, remote_port, local_host=nil, local_port=nil)
    if Sockit.connect_via_socks?(remote_host)
      initialize_tcp(Sockit.config.host, Sockit.config.port)
      (Sockit.config.version.to_i == 5) and Sockit.authenticate(self)
      Sockit.config.host and Sockit.connect(self, remote_host, remote_port)
    else
      Sockit.direct_connection(self, remote_host, remote_port, local_host, local_port)
    end
  end

  extend Sockit::Authentication
end
