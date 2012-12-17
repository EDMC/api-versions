module ApiVersions
  class DSL
    extend Forwardable

    def initialize(context, &block)
      @context = context
      singleton_class.def_delegators :@context, *(@context.public_methods - public_methods)
      instance_eval(&block)
    end

    def version(version_number, &block)
      VersionCheck.default_version ||= version_number

      constraints VersionCheck.new(version: version_number) do
        scope({ module: "v#{version_number}" }, &block)
      end
    end

    def inherit(options)
      Array.wrap(options[:from]).each do |block|
         @resource_cache[block].call
      end
    end

    def cache(options, &block)
      @resource_cache ||= {}
      @resource_cache[options[:as]] = block
      yield
    end
  end
end
