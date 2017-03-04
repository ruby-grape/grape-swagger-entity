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
  s.homepage      = 'https://github.com/ruby-grape/grape-swagger-entity'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.2.6'
  s.add_runtime_dependency 'grape-swagger', '>= 0.20.4'
  s.add_runtime_dependency 'grape-entity', '>= 0.5.0'
end
