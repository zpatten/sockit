# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sockit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Zachary Patten"]
  gem.email         = ["zachary@jovelabs.com"]
  gem.description   = %q{SOCKS 4/5 support for TCPSockets}
  gem.summary       = %q{SOCKS 4/5 support for TCPSockets}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sockit"
  gem.require_paths = ["lib"]
  gem.version       = Sockit::VERSION
end
