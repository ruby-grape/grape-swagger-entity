$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'grape-swagger/entity'
require 'grape'

Bundler.setup :default, :test

require 'rack'
require 'rack/test'

RSpec.configure do |config|
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.mock_with :rspec
  config.include Rack::Test::Methods
  config.raise_errors_for_deprecations!

  config.order = 'random'
  config.seed = 40_834
end

Dir['spec/support/**/*.rb'].each { |file| require "./#{file}" }
