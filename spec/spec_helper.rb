require 'coveralls'

Coveralls.wear! do
  add_filter "/spec/"
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'ammeter/init'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = true
  config.order = "random"
end
