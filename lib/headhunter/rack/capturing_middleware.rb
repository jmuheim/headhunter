module Headhunter
  module Rack
    class CapturingMiddleware
      def initialize(app, headhunter)
        @app = app
        @hh  = headhunter
      end

      def call(env)
        response = @app.call(env)
        process(response)
        response
      end

      def process(rack_response)
        status, headers, response = rack_response

        if html = extract_html_from(response)
          @hh.process!('unknown', html)
        end
      end

      def extract_html_from(response)
        response[0]
      end
    end
  end
end
