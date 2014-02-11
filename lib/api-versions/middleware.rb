module ApiVersions
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      accept_string = env['HTTP_ACCEPT'] || ""
      accepts = accept_string.split(',')
      accepts.push("application/vnd.#{ApiVersions::VersionCheck.vendor_string}+json") unless accept_string.include?('application/vnd.')
      offset = 0
      accepts.dup.each_with_index do |accept, i|
        accept.strip!
        match = /\Aapplication\/vnd\.#{ApiVersions::VersionCheck.vendor_string}\s*\+\s*(?<format>\w+)\s*/.match(accept)
        if match
          accepts.insert i + offset, "application/#{match[:format]}"
          offset += 1
        end
      end

      # Add a space between plus and xml to work around a Rails 4 bug
      env['HTTP_ACCEPT'] = accepts.join(',').gsub("+xml", "+ xml")
      @app.call(env)
    end
  end
end
