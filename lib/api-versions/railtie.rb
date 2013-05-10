require 'rails/railtie'

module ApiVersions
  class Railtie < Rails::Railtie
    config.app_middleware.use ApiVersions::Middleware
  end
end
