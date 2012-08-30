require "api-versions/version"
require "api-versions/version_check"
require "api-versions/dsl"

module ApiVersions
  def api(options = {}, &block)
    VersionCheck.default_version = options[:default_version]
    VersionCheck.vendor_string   = options[:vendor_string]

    raise "Please set a vendor_string for the api method" if options[:vendor_string].nil?

    namespace(:api) { DSL.new(self, &block) }
  end
end

ActionDispatch::Routing::Mapper.send :include, ApiVersions
