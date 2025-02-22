# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in grape-swagger-entity.gemspec
gemspec

gem 'grape', case version = ENV.fetch('GRAPE_VERSION', '< 3.0')
             when 'HEAD'
               { git: 'https://github.com/ruby-grape/grape' }
             else
               version
             end
gem 'grape-swagger', case version = ENV.fetch('GRAPE_SWAGGER', 'HEAD')
                     when 'HEAD'
                       { git: 'https://github.com/ruby-grape/grape-swagger.git' }
                     else
                       version
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
  gem 'grape-entity', case version = ENV.fetch('GRAPE_ENTITY', '1.0.1')
                      when 'HEAD'
                        { git: 'https://github.com/ruby-grape/grape-entity.git' }
                      else
                        version
                      end
  gem 'ruby-grape-danger', '~> 0.2.1', require: false
  gem 'simplecov', require: false
end
