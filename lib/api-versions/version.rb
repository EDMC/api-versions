module ApiVersions
  class Version
    MAJOR = 1
    MINOR = 2
    PATCH = 1

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end

  VERSION = Version.to_s
end
