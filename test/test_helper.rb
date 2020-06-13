# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails" do
  add_filter "/app/channels/"
  add_filter "/app/jobs/"
  add_filter "/app/mailers/"
  add_filter "/lib/api/"
end
require "mocha/minitest"
Minitest::Reporters.use!

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :minitest

    with.library :rails
  end
end

if ENV["CI"] == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  def valid_get(uri, opts = {})
    params = {}
    params[:params] = opts[:params] || {}
    params[:headers] = { "Content-Type": "application/vnd.api+json", "Accept": "application/vnd.api+json" }
    send :get, uri, params
  end

  def valid_post(uri, opts = {})
    params = {}
    params[:params] = opts[:params] || {}
    params[:headers] = { "Content-Type": "application/vnd.api+json", "Accept": "application/vnd.api+json" }
    send :post, uri, params
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include ::RequestHelpers
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Add more helper methods to be used by all tests here...
end
