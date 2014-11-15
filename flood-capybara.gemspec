# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flood/capybara/version'

Gem::Specification.new do |spec|
  spec.name          = "flood-capybara"
  spec.version       = Flood::Capybara::VERSION
  spec.authors       = ["Tim Koopmans"]
  spec.email         = ["tim@flood.io"]
  spec.summary       = %q{Run your Capybara RSpec test cases on Flood IO}
  spec.description   = %q{Run your Capybara RSpec test cases on Flood IO}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "poltergeist"
  spec.add_development_dependency "elasticsearch"
  spec.add_development_dependency "elasticsearch-api"
  spec.add_development_dependency "selenium-webdriver"

  spec.add_dependency "parser"
  spec.add_dependency "unparser"
  spec.add_dependency "rest-client"
end
