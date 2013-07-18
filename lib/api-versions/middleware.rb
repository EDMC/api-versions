module ApiVersions
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless env['HTTP_ACCEPT']

      accepts = env['HTTP_ACCEPT'].split(',')
      offset = 0
      accepts.dup.each_with_index do |accept, i|
        accept.strip!
        match = /\Aapplication\/vnd\.#{ApiVersions::VersionCheck.vendor_string}\s*\+\s*(?<format>\w+)\s*/.match(accept)
        if match
          accepts.insert i + offset, "application/#{match[:format]}"
          offset += 1
        end
      end

      request = Rack::Request.new(env)
      if request.path.include?('api') && !env['HTTP_ACCEPT'].include?("vnd.#{ApiVersions::VersionCheck.vendor_string}")
        accepts.insert accepts.size - 1, "application/vnd.#{ApiVersions::VersionCheck.vendor_string}"
      end

      env['HTTP_ACCEPT'] = accepts.join(',')
      @app.call(env)
    end
  end
end
