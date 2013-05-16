module ApiVersions
  MAJOR = 1
  MINOR = 2
  PATCH = 0
  PRE   = nil

  VERSION = [MAJOR, MINOR, PATCH, PRE].compact.join '.'
end
