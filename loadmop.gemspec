# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loadmop/version'

Gem::Specification.new do |spec|
  spec.name          = 'loadmop'
  spec.version       = Loadmop::VERSION
  spec.authors       = ['Ryan Duryea']
  spec.email         = ['aguynamedryan@gmail.com']
  spec.summary       = %q{Ruby-based script to load OMOP Vocabulary/CDMv4 data into a database}
  spec.description   = %q{loadmop assits in loading OMOP Vocabulary files and OMOP CDMv4-compatible CSV files into your database}
  spec.homepage      = 'https://github.com/outcomesinsights/loadmop'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_dependency 'rake', '~> 10.3'
  spec.add_dependency 'sequelizer', '>= 0.0.5'
  spec.add_dependency 'thor', '~> 0.19'
end
