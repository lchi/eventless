# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "eventless/version"

Gem::Specification.new do |s|
  s.name        = "eventless"
  s.version     = Eventless::VERSION
  s.authors     = ["David Albert"]
  s.email       = ["davidbalbert@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "eventless"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extensions = ["ext/sockaddr/extconf.rb"]

  s.add_dependency("cool.io")
  s.add_dependency("ipaddress")

  # for resolver/cares.rb, which doesn't fully work yet
  # s.add_dependency("ruby-cares")

  s.add_development_dependency("rake-compiler")
end
