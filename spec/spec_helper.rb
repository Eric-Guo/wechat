if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_group 'Libraries', 'lib'
  end
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'

Dir[File.join(File.dirname(__FILE__), "../spec/support/**/*.rb")].sort.each {|f| require f}
RSpec.configure do |config|
  config.color = true
  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = true
  config.order = "random"
end
