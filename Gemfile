# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in grape-swagger-entity.gemspec
gemspec

grape_version = ENV.fetch('GRAPE_VERSION', '< 3.0')
grape_swagger_version = ENV.fetch('GRAPE_SWAGGER_VERSION', '< 3.0')
grape_entity_version = ENV.fetch('GRAPE_ENTITY_VERSION', '< 2.0')

grape_spec = grape_version.casecmp('HEAD').zero? ? { git: 'https://github.com/ruby-grape/grape' } : grape_version
grape_swagger_spec = if grape_swagger_version.casecmp('HEAD').zero?
                       { git: 'https://github.com/ruby-grape/grape-swagger.git' }
                     else
                       grape_swagger_version
                     end
grape_entity_spec = if grape_entity_version.casecmp('HEAD').zero?
                      { git: 'https://github.com/ruby-grape/grape-entity.git' }
                    else
                      grape_entity_version
                    end

gem 'grape', grape_spec
gem 'grape-swagger', grape_swagger_spec

group :development, :test do
  gem 'bundler'
  gem 'pry', platforms: [:mri]
  gem 'pry-byebug', platforms: [:mri]
  gem 'rack'
  gem 'rack-cors'
  gem 'rack-test'
  gem 'rake'
  gem 'rdoc'
  gem 'rspec'
end

group :development do
  gem 'rubocop', '>= 1.72', require: false
  gem 'rubocop-rake', '>= 0.7', require: false
  gem 'rubocop-rspec', '>= 3.5.0', require: false
end

group :test do
  gem 'grape-entity', grape_entity_spec
  gem 'ruby-grape-danger', '~> 0.3.0', require: false
  gem 'simplecov', require: false
end
