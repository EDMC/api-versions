require "api-versions/version"

class Engine < Rails::Engine
  initializer "api_versions" do
    config.to_prepare { ActionDispatch::Routing::Mapper.send :include, ApiVersions }
  end
end

module ApiVersions

  def inherit_resources(args)
    [*args[:from]].each do |block|
      @resource_cache[block].call
    end
  end
    
  def cache_resources(args, &block)
    @resource_cache ||= {}
    @resource_cache.merge!(args[:as] => block)
    block.call
  end
  
  def api_version=(version)
    ApiVersions::ApiVersionCheck.api_version = version
  end
  alias_method :default_api_version, :api_version=
  
  
  def vendor=(vendor)
    ApiVersions::ApiVersionCheck.api_vendor = vendor
  end
  alias_method :api_vendor, :vendor=
  
  def api_version_check(*args)
    ApiVersions::ApiVersionCheck.new(*args)
  end
  
  class ApiVersionCheck
    
    cattr_accessor :api_version, :api_vendor

    def initialize(args = {})
      @process_version = args[:version]
    end

    def matches?(request)
      accepts_proper_format?(request) && (matches_version?(request) || unversioned?(request))
    end
    
    private

    def accepts_proper_format?(request)
      !!(request.headers['Accept'] =~ /^application\/vnd\.#{self.class.api_vendor}\+?.+/)
    end

    def matches_version?(request)
      !!(request.headers['Accept'] =~ /version\s*?=\s*?#{@process_version}\b/)
    end

    def unversioned?(request)
        @process_version == self.class.api_version && !(request.headers['Accept'] =~ /version\s*?=\s*?\d*\b/i)
    end
    
  end
end
