# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loadmop/version'

Gem::Specification.new do |spec|
  spec.name          = 'loadmop'
  spec.version       = Loadmop::VERSION
  spec.authors       = ['Ryan Duryea']
  spec.email         = ['aguynamedryan@gmail.com']
  spec.summary       = %q{Ruby-based script to load OMOP Vocabulary into a database}
  spec.description   = %q{}
  spec.homepage      = ''
  spec.license       = 'Apache License, Version 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_dependency 'rake'
  spec.add_dependency 'thor'
end
