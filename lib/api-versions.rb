require "api-versions/version"

module ApiVersions
  class DSL
    extend Forwardable

    def initialize(context, &block)
      @context = context
      self.class.def_delegators :@context, *(@context.public_methods - public_methods)
      instance_eval &block
    end

    def version(version_number, &block)
      VersionCheck.default_version ||= version_number

      constraints VersionCheck.new(version: version_number) do
        scope({ module: "v#{version_number}" }, &block)
      end
    end

    def inherit(args)
      [*args[:from]].each do |block|
         @resource_cache[block].call
      end
    end

    def cache(args, &block)
      @resource_cache ||= {}
      @resource_cache[args[:as]] = block
      block.call
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

    raise "Please set a vendor_string for the api method" if options[:vendor_string].nil?

    namespace(:api) { DSL.new(self, &block) }
  end
end

ActionDispatch::Routing::Mapper.send :include, ApiVersions
