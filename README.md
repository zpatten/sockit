[![Gem Version](https://badge.fury.io/rb/sockit.png)](http://badge.fury.io/rb/sockit)
[![Build Status](https://secure.travis-ci.org/zpatten/sockit.png)](http://travis-ci.org/zpatten/sockit)
[![Coverage Status](https://coveralls.io/repos/zpatten/sockit/badge.png?branch=master)](https://coveralls.io/r/zpatten/sockit)
[![Dependency Status](https://gemnasium.com/zpatten/sockit.png)](https://gemnasium.com/zpatten/sockit)
[![Code Climate](https://codeclimate.com/github/zpatten/sockit.png)](https://codeclimate.com/github/zpatten/sockit)

# SOCKIT

Transparent SOCKS v4 and SOCKS v5 support for TCPSocket

Seamlessly route all TCP traffic for you application through a SOCKS v4 or v5 server with nearly zero effort.  Once `require`'d and configured all traffic leveraging the `TCPSocket` class will route via your configured SOCKS server.

This is especially useful for many cases; here are a couple:

- Ensure all outbound traffic from your application appears from a single IP.
- Ensure development traffic does not give away private IP addresses.

## INSTALLATION

Add this line to your application's Gemfile:

    gem 'sockit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sockit

## USAGE

By loading the gem TCPSocket will get monkey patched adding seamless transparent SOCKS proxy support.  I favor using SS5 for a SOCKS server, so at this point I'm uncertain of absolute compatibility with other SOCKS servers.  I'm following the RFC here; so if (insert other SOCKS server flavor here) follows the RFC everything is in theory compatible.

### CONFIGURATION

You can configure on the singleton class or an instance of the class.  The SOCKS configuration is stored in a class variable; so it is shared across all TCPSocket instances and the singleton, thus changing the configuration in one instance will also affect all other instances.  The configuration is stored in an OpenStruct; you can reference `socks` with a block as shown, where the configuration OpenStruct is yielded to the block; or without in which case the configuration OpenStruct itself is returned.

The defaults are as follows:

    Sockit.config do |config|
      config.version = 5
      config.ignore = ["127.0.0.1"]
      config.debug = false
    end

Specify your SOCKS server and port:

    Sockit.config do |config|
      config.host = "127.0.0.1"
      config.port = "1080"
    end

If you want to use username/password authentication:

    Sockit.config do |config|
      config.username = "username"
      config.password = "password"
    end

Turn on debug output:

    Sockit.config do |config|
      config.debug = true
    end

Ignore some more hosts:

    Sockit.config do |config|
      config.ignore << "192.168.0.1"
    end

Once configured you can simply do something along these lines:

    socket = TCPSocket.new('github.com', '22')
    data = socket.gets
    puts data.inspect

And everything will be magically routed via your configured SOCKS server.

## SS5

I use SS5 for my SOCKS servers.  It works well and is easy to configure.  It is also the server which the specs run against on Travis CI.  You can see how it is compiled, configured and started as well as more the the Travis `before_install` script, https://github.com/zpatten/sockit/blob/master/spec/support/before_install.sh

## CONTRIBUTING

I await your pull request.

# RESOURCES

IRC:

* #jovelabs on irc.freenode.net

Documentation:

* http://zpatten.github.io/sockit/

Source:

* https://github.com/zpatten/sockit

Issues:

* https://github.com/zpatten/sockit/issues

# LICENSE

SOCKIT - Transparent SOCKS 5 support for TCPSocket

* Author: Zachary Patten <zachary AT jovelabs DOT com> [![endorse](http://api.coderwall.com/zpatten/endorsecount.png)](http://coderwall.com/zpatten)
* Copyright: Copyright (c) Zachary Patten
* License: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
