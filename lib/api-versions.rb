require "api-versions/version"

module ApiVersions
  def has_common_resources
    include InstanceMethods
  end
  
  def api_version=(version)
    @@version = version
  end
  
  def vendor=(vendor)
    @@vendor = vendor
  end
  
  module InstanceMethods
    def inherit_resources(args)
      @resource_cache[args[:from]].call
    end
    
    def cache_resources(args, &block)
      @resource_cache ||= {}
      @resource_cache.merge!(args[:as] => block)
      block.call
    end
  end
  
  class ApiVersionCheck

    def initialize(args = {})
      @version = args[:version]
    end

    def matches?(request)
      accepts_proper_format?(request) && (matches_version?(request) || unversioned?(request))
    end
    
    private

    def accepts_proper_format?(request)
      !!(request.headers['Accept'] =~ /^application\/vnd\.#{@@vendor}\+json/)
    end

    def matches_version?(request)
      !!(request.headers['Accept'] =~ /version\s*?=\s*?#{@version}\b/)
    end

    def unversioned?(request)
        @version == @@version && !(request.headers['Accept'] =~ /version\s*?=\s*?\d*\b/i)
    end
    
  end
end
