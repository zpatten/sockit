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

# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sockit/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "sockit"
  spec.version       = Sockit::VERSION
  spec.authors       = %(Zachary Patten)
  spec.email         = [ %(zachary AT jovelabs DOT com) ]
  spec.description   = %(Seamlessly route all TCP traffic for you application through a SOCKS v4 or v5 server with nearly zero effort.  Once required and configured all traffic leveraging the TCPSocket class will route via your configured SOCKS server.)
  spec.summary       = %(Transparent SOCKS v4 and SOCKS v5 support for TCPSocket)
  spec.homepage      = %(https://github.com/zpatten/sockit)
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency("pry")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("yard")
  spec.add_development_dependency("redcarpet")
  spec.add_development_dependency("coveralls")
  spec.add_development_dependency("yarjuf")
  spec.add_development_dependency("simplecov-rcov")
  spec.add_development_dependency("travis")
  spec.add_development_dependency("websocket-native")
  spec.add_development_dependency("ztk")
end
