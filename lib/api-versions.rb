require "api-versions/version"

module ApiVersions
  class Methods
    def initialize(context, &block)
      @context = context
      instance_eval &block
    end

    def method_missing(meth, *args)
      @context.send(meth, *args)
    end

    def version(version_number, &block)
      VersionCheck.default_version = version_number if VersionCheck.default_version.nil?

      @context.instance_eval do
        constraints ApiVersions::VersionCheck.new(version: version_number) do
          scope({ module: "v#{version_number}" }, &block)
        end
      end
    end

    def inherit(args)
      [*args[:from]].each do |block|
        @context.instance_eval &@resource_cache[block]
      end
    end

    def cache(args, &block)
      @resource_cache ||= {}
      @resource_cache[args[:as]] = block
      @context.instance_eval &block
    end
  end

  class VersionCheck
    cattr_accessor :default_version, :vendor_string

    def initialize(args = {})
      @process_version = args[:version]
    end

    def matches?(request)
      accepts_proper_format?(request) && (matches_version?(request) || unversioned?(request))
    end

    private

    def accepts_proper_format?(request)
      !!(request.headers['Accept'] =~ /^application\/vnd\.#{self.class.vendor_string}\+.+/)
    end

    def matches_version?(request)
      !!(request.headers['Accept'] =~ /version\s*?=\s*?#{@process_version}\b/)
    end

    def unversioned?(request)
        @process_version == self.class.default_version && !(request.headers['Accept'] =~ /version\s*?=\s*?\d*\b/i)
    end
  end

  def api(options = {}, &block)
    VersionCheck.default_version = options[:default_version]
    VersionCheck.vendor_string   = options[:vendor_string]

    namespace(:api) { Methods.new(self, &block) }
  end
end

ActionDispatch::Routing::Mapper.send :include, ApiVersions
