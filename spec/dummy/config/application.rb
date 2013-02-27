require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "action_controller/railtie"

if defined?(Rails.groups)
  Bundler.require(*Rails.groups)
else
  Bundler.require
end
require "api-versions"

module Dummy
  class Application < Rails::Application
  end
end

