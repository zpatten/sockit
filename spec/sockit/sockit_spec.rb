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
      expect(subject.config.host).to eq nil
      expect(subject.config.port).to eq nil
    end

    it "should report as configured when it is" do
      Sockit.config.version = 5
      Sockit.config.host = "127.0.0.1"
      Sockit.config.port = "1080"

      expect(Sockit.is_configured?).to eq true
    end

    it "should not report as configured when it is not" do
      Sockit.config.version = 5
      Sockit.config.host = "127.0.0.1"
      Sockit.config.port = ""

      expect(Sockit.is_configured?).to eq false
    end

    it "should report as SOCKS v5 when configured as such" do
      Sockit.config.version = 5
      Sockit.config.host = "127.0.0.1"
      Sockit.config.port = "1080"

      expect(Sockit.is_socks_v5?).to eq true
    end

    it "should not report as SOCKS v5 when configured as such" do
      Sockit.config.version = 5
      Sockit.config.host = ""
      Sockit.config.port = "1080"

      expect(Sockit.is_socks_v5?).to eq false
    end

    it "should report as SOCKS v4 when configured as such" do
      Sockit.config.version = 4
      Sockit.config.host = "127.0.0.1"
      Sockit.config.port = "1080"

      expect(Sockit.is_socks_v4?).to eq true
    end

    it "should not report as SOCKS v4 when configured as such" do
      Sockit.config.version = 4
      Sockit.config.host = ""
      Sockit.config.port = "1080"

      expect(Sockit.is_socks_v4?).to eq false
    end

  end

end
