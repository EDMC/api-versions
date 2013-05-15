require "api-versions/version"
require "api-versions/version_check"
require "api-versions/dsl"
require 'api-versions/middleware'
require 'api-versions/railtie'

module ApiVersions
  def api(options = {}, &block)
    raise "Please set a vendor_string for the api method" if options[:vendor_string].nil?

    VersionCheck.default_version = options[:default_version]
    VersionCheck.vendor_string   = options[:vendor_string]

    namespace(:api, options) { DSL.new(self, &block) }
  end
end

ActionDispatch::Routing::Mapper.send :include, ApiVersions
