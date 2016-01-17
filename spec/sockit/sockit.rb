################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
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

describe Sockit do

  subject { Sockit }

  describe "class" do

    it "should be Sockit" do
      expect(subject).to be Sockit
    end

    it "should have a default config" do
      expect(subject.config.debug).to eq false
      expect(subject.config.username).to eq nil
      expect(subject.config.password).to eq nil
      expect(subject.config.host).to eq "127.0.0.1"
      expect(subject.config.port).to eq "1080"
    end

  end

end

describe TCPSocket do

  describe "instance" do

    describe "methods" do

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

      it "should allow a SOCKS connection to github" do
        Sockit.config do |config|
          config.version = 5
          config.host = "127.0.0.1"
          config.port = "1080"
        end

        socket = TCPSocket.new('github.com', '22')
        data = socket.gets
        expect(data).to match(/SSH/)
      end

    end

  end

end



# require 'bundler/setup'
# require 'sockit'

# Sockit.config do |config|
#   config.version = 5
#   config.debug = true
#   config.host = "127.0.0.1"
#   config.port = "1080"
# end

# socket = TCPSocket.new('www.google.com', '80')
# puts socket.read.inspect
