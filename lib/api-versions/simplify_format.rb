module ApiVersions
  module SimplifyFormat
    extend ActiveSupport::Concern

    included do
      before_filter :simplify_format
    end

    private

    def simplify_format
      request.headers['Accept'] && request.headers['Accept'].match(/\+\s*(.+?)[;\s]/) { |m| request.format = m[1] }
    end
  end
end
