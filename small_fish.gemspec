# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'small_fish/version'

Gem::Specification.new do |spec|
  spec.name          = "small_fish"
  spec.version       = SmallFish::VERSION
  spec.authors       = ["hunter"]
  spec.email         = ["hunter.wxhu@gmail.com"]
  spec.description   = %q{small_fish}
  spec.summary       = %q{small_fish}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib","bin","config","init","spec"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
