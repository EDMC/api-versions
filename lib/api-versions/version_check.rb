module ApiVersions
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
      request.headers['Accept'] =~ /\Aapplication\/vnd\.#{self.class.vendor_string}\+.+/
    end

    def matches_version?(request)
      request.headers['Accept'] =~ /version\s*?=\s*?#{@process_version}\b/
    end

    def unversioned?(request)
      @process_version == self.class.default_version && !(request.headers['Accept'] =~ /version\s*?=\s*?\d*\b/i)
    end
  end
end
