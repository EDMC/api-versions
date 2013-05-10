module ApiVersions
  class VersionCheck
    class << self
      attr_accessor :default_version, :vendor_string
    end

    def initialize(args = {})
      @process_version = args[:version]
    end

    def matches?(request)
      accepts = request.headers['Accept'].split(',')
      accepts.any? do |accept|
        accept.strip!
        accepts_proper_format?(accept) && (matches_version?(accept) || unversioned?(accept))
      end
    end

    private

    def accepts_proper_format?(accept_string)
      accept_string =~ /\Aapplication\/vnd\.#{self.class.vendor_string}\s*\+\s*.+/
    end

    def matches_version?(accept_string)
      accept_string =~ /version\s*?=\s*?#{@process_version}\b/
    end

    def unversioned?(accept_string)
      @process_version == self.class.default_version && !(accept_string =~ /version\s*?=\s*?\d*\b/i)
    end
  end
end
