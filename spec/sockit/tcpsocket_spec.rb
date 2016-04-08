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

require "spec_helper"

describe "TCPSocket" do

  after(:all) do
    Sockit.config do |config|
      config.version = nil
      config.host = nil
      config.port = nil
    end
  end

  describe "connections" do

    describe "direct" do

      it "should allow a direct connection to github" do
        Sockit.config do |config|
          config.version = nil
          config.host = nil
          config.port = nil
        end

        socket = TCPSocket.new('github.com', '22')
        data = socket.gets
        expect(data).to match(/SSH/)
      end

    end

    describe "SOCKS v5" do

      it "should allow a SOCKS v4 connection to github (no debug/no auth)" do
        Sockit.config do |config|
          config.debug = false
          config.version = 4
          config.host = "127.0.0.1"
          config.port = "1080"
          config.username = nil
          config.password = nil
        end

        socket = TCPSocket.new('github.com', '22')
        data = socket.gets
        expect(data).to match(/SSH/)
      end

      it "should allow a SOCKS v5 connection to github (no debug/no auth)" do
        Sockit.config do |config|
          config.debug = false
          config.version = 5
          config.host = "127.0.0.1"
          config.port = "1080"
          config.username = nil
          config.password = nil
        end

        socket = TCPSocket.new('github.com', '22')
        data = socket.gets
        expect(data).to match(/SSH/)
      end

      it "should allow a SOCKS v5 connection to github (debug/no auth)" do
        Sockit.config do |config|
          config.debug = true
          config.version = 5
          config.host = "127.0.0.1"
          config.port = "1080"
          config.username = nil
          config.password = nil
        end

        socket = TCPSocket.new('github.com', '22')
        data = socket.gets
        expect(data).to match(/SSH/)
      end

      it "should allow a SOCKS v5 connection to github (no debug/auth)" do
        Sockit.config do |config|
          config.debug = false
          config.version = 5
          config.host = "127.0.0.1"
          config.port = "1081"
          config.username = "root"
          config.password = "none"
        end

        socket = TCPSocket.new('github.com', '22')
        data = socket.gets
        expect(data).to match(/SSH/)
      end

      it "should allow a SOCKS v5 connection to github (debug/auth)" do
        Sockit.config do |config|
          config.debug = true
          config.version = 5
          config.host = "127.0.0.1"
          config.port = "1081"
          config.username = "root"
          config.password = "none"
        end

        socket = TCPSocket.new('github.com', '22')
        data = socket.gets
        expect(data).to match(/SSH/)
      end

      it "should throw an exception if we use bad credentials (no debug/auth)" do
        Sockit.config do |config|
          config.debug = false
          config.version = 5
          config.host = "127.0.0.1"
          config.port = "1081"
          config.username = "root"
          config.password = "blargh"
        end

        expect{ TCPSocket.new('github.com', '22') }.to raise_exception(SockitError)
      end

    end

  end

end
