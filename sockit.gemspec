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

Gem::Specification.new do |gem|
  gem.authors       = ["Zachary Patten"]
  gem.email         = ["zachary@jovelabs.com"]
  gem.description   = %q{Transparent SOCKS 5 support for TCPSocket}
  gem.summary       = %q{Transparent SOCKS 5 support for TCPSocket}
  gem.homepage      = "https://github.com/zpatten/sockit"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sockit"
  gem.require_paths = ["lib"]
  gem.version       = Sockit::VERSION

  gem.add_development_dependency("pry")
  gem.add_development_dependency("yard")
  gem.add_development_dependency("redcarpet")
end
