# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape-swagger/entity/version'

Gem::Specification.new do |s|
  s.name          = 'grape-swagger-entity'
  s.version       = GrapeSwagger::Entity::VERSION
  s.authors       = ['Kirill Zaitsev']
  s.email         = ['kirik910@gmail.com']

  s.summary       = 'Grape swagger adapter to support grape-entity object parsing'
  s.homepage      = 'https://github.com/Bugagazavr/grape-swagger-entity'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'grape-swagger', '>= 0.20.4'
  s.add_runtime_dependency 'grape-entity'

  s.add_development_dependency 'bundler', '~> 1.12'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rack-cors'
  s.add_development_dependency 'rubocop', '0.40.0'
  s.add_development_dependency 'redcarpet' unless RUBY_PLATFORM.eql?('java') || RUBY_ENGINE.eql?('rbx')
  s.add_development_dependency 'rouge' unless RUBY_PLATFORM.eql?('java') || RUBY_ENGINE.eql?('rbx')
  s.add_development_dependency 'pry' unless RUBY_PLATFORM.eql?('java') || RUBY_ENGINE.eql?('rbx')
  s.add_development_dependency 'pry-byebug' unless RUBY_PLATFORM.eql?('java') || RUBY_ENGINE.eql?('rbx')
end
