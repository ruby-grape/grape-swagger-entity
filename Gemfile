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

# grape < 2.1 calls Mustermann::Pattern#named_captures, which mustermann 4 removed.
old_grape = grape_spec.is_a?(String) && !Gem::Requirement.new(grape_spec).satisfied_by?(Gem::Version.new('2.1'))
gem 'mustermann', '< 4' if old_grape

# activesupport 7.1, the last release for Ruby 3.0, passes quirks_mode to JSON.generate, which json 3 removed.
gem 'json', '< 3' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.1')

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
  gem 'danger', require: false
  gem 'danger-changelog', require: false
  gem 'danger-pr-comment', require: false
  gem 'danger-toc', require: false
  gem 'grape-entity', grape_entity_spec
  gem 'simplecov', require: false
end
