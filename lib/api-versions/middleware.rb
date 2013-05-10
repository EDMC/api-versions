module ApiVersions
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      accepts = env['HTTP_ACCEPT'].split(',')
      offset = 0
      accepts.dup.each_with_index do |accept, i|
        accept.strip!
        match = /\Aapplication\/vnd\.#{ApiVersions::VersionCheck.vendor_string}\s*\+\W*(?<format>\w+)\W*/.match(accept)
        if match
          accepts.insert i + offset, "application/#{match[:format]}"
          offset += 1
        end
      end

      env['HTTP_ACCEPT'] = accepts.join(',')
      @app.call(env)
    end
  end
end
