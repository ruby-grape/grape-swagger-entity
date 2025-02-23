# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in grape-swagger-entity.gemspec
gemspec

grape_version = ENV.fetch('GRAPE_VERSION', '< 3.0')
grape_swagger_version = ENV.fetch('GRAPE_SWAGGER', 'HEAD')
grape_entity_version = ENV.fetch('GRAPE_ENTITY', '1.0.1')

gem 'grape', if grape_version.casecmp('HEAD').zero?
               { git: 'https://github.com/ruby-grape/grape' }
             else
               grape_version
             end
gem 'grape-swagger', if grape_swagger_version.casecmp('HEAD').zero?
                       { git: 'https://github.com/ruby-grape/grape-swagger.git' }
                     else
                       grape_swagger_version
                     end

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
  gem 'rubocop'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
end

group :test do
  gem 'grape-entity', if grape_entity_version.casecmp('HEAD').zero?
                        { git: 'https://github.com/ruby-grape/grape-entity.git' }
                      else
                        grape_entity_version
                      end
  gem 'ruby-grape-danger', '~> 0.2.1', require: false
  gem 'simplecov', require: false
end
