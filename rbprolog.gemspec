# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbprolog/version'

Gem::Specification.new do |spec|
  spec.name          = "rbprolog"
  spec.version       = Rbprolog::VERSION
  spec.authors       = ["Ruijia Li"]
  spec.email         = ["ruijia.li@gmail.com"]
  spec.description   = %q{A ruby implementation to simulate prolog partially}
  spec.summary       = %q{A prolog DSL in ruby to do AI logic analysis}
  spec.homepage      = "https://github.com/rli9/rbprolog"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.metadata = { "Source Code" => "https://github.com/rli9/rbprolog" }

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
