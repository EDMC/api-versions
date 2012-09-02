require File.expand_path('../boot', __FILE__)
require "action_controller/railtie"

Bundler.require
require "api-versions"

module Dummy
  class Application < Rails::Application
    config.encoding = "utf-8"
  end
end

