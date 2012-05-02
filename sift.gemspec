# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sift/version"

Gem::Specification.new do |s|
  s.name        = "sift"
  s.version     = Sift::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Fred Sadaghiani"]
  s.email       = ["freds@siftscience.com"]
  s.homepage    = "http://siftscience.com"
  s.summary     = %q{Sift Science Ruby API Gem}
  s.description = %q{The description goes here}

  s.rubyforge_project = "sift"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Gems that must be intalled for sift to compile and build
  s.add_development_dependency "rspec", "~> 2.9.0"
  s.add_development_dependency "fakeweb", "~> 1.3.0"

  # Gems that must be intalled for sift to work
  s.add_dependency "httparty", ">= 0.8.3"
  s.add_dependency "multi_json", ">= 1.3.4"
end
