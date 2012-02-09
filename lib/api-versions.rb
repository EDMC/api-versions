require "api-versions/version"

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
    @@version = version
  end
  
  def vendor=(vendor)
    @@vendor = vendor
  end
  
  class ApiVersionCheck

    def initialize(args = {})
      @process_version = args[:version]
    end

    def matches?(request)
      accepts_proper_format?(request) && (matches_version?(request) || unversioned?(request))
    end
    
    private

    def accepts_proper_format?(request)
      !!(request.headers['Accept'] =~ /^application\/vnd\.#{@@vendor}\+json/)
    end

    def matches_version?(request)
      !!(request.headers['Accept'] =~ /version\s*?=\s*?#{@process_version}\b/)
    end

    def unversioned?(request)
        @process_version == @@version && !(request.headers['Accept'] =~ /version\s*?=\s*?\d*\b/i)
    end
    
  end
end
