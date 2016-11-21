source 'https://rubygems.org'

# Specify your gem's dependencies in grape-swagger-entity.gemspec
gemspec

gem 'grape-entity', ENV.fetch('GRAPE_ENTITY', '0.5.0')
gem 'grape-swagger', github: 'ruby-grape/grape-swagger'
gem 'ruby-grape-danger', '~> 0.1.0', require: false

if RUBY_VERSION < '2.2.2'
  gem 'rack', '<2.0.0'
  gem 'activesupport', '<5.0.0'
end
