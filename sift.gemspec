# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sift/version"

Gem::Specification.new do |s|
  s.name        = "sift"
  s.version     = Sift::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Fred Sadaghiani", "Yoav Schatzberg", "Jacob Burnim"]
  s.email       = ["support@siftscience.com"]
  s.homepage    = "http://siftscience.com"
  s.summary     = %q{Sift Science Ruby API Gem}
  s.description = %q{Sift Science Ruby API. Please see http://siftscience.com for more details.}

  s.rubyforge_project = "sift"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Gems that must be intalled for sift to compile and build
  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "pry"
  s.add_development_dependency "webmock", ">= 1.16.0", "< 2"

  # Gems that must be intalled for sift to work
  s.add_dependency "httparty", ">= 0.11.0"
  s.add_dependency "multi_json", ">= 1.0"

  s.add_development_dependency("rake")
end
