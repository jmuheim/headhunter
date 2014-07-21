module Headhunter
  module Rack
    class CapturingMiddleware
      def initialize(app, headhunter)
        @app = app
        @hh  = headhunter
      end

      def call(env)
        url = env['PATH_INFO'] || 'unknown'
        response = @app.call(env)
        process(url, response)
        response
      end

      def process(url, rack_response)
        status, headers, response = rack_response

        if html = extract_html_from(response)
          @hh.process(url, html)
        end
      end

      def extract_html_from(response)
        response[0] if response.respond_to? :[]
      end
    end
  end
end
