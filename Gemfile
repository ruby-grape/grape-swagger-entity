source 'https://rubygems.org'

# Specify your gem's dependencies in grape-swagger-entity.gemspec
gemspec

group :development, :test do
  gem 'bundler'
  gem 'pry', platforms: [:mri]
  gem 'pry-byebug', platforms: [:mri]
  gem 'rack'
  gem 'rack-cors'
  gem 'rack-test'
  gem 'rake'
  gem 'rdoc'
  gem 'rspec', '~> 3.0'
  gem 'rubocop', '~> 0.48'
end

gem 'grape-swagger', git: 'https://github.com/ruby-grape/grape-swagger.git'

group :test do
  gem 'grape-entity', ENV.fetch('GRAPE_ENTITY', '0.6.1')
  gem 'ruby-grape-danger', '~> 0.1.1', require: false
  gem 'simplecov', require: false
end
