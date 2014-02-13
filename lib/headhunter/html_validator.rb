require 'html_validation'

module Headhunter
  class HtmlValidator
    # TODO: Is path a good name? It implies the executable file is in it, too. Shouldn't it be something like VALIDATOR_HOME/DIR?
    VALIDATOR_PATH = Gem.loaded_specs['headhunter'].full_gem_path + '/lib/tidy/'

    attr_reader :responses

    def initialize
      @responses = []
    end

    def validate(uri, html)
      Dir.chdir(VALIDATOR_PATH) do
        # Docs for Tidy: http://tidy.sourceforge.net/docs/quickref.html
        stdin, stdout, stderr = Open3.popen3('tidy -quiet')
        stdin.puts html
        stdin.close
        stdout.close

        @responses << Response.new(stderr.read, uri)
        stderr.close
      end

      @responses.last
    end

    def valid_responses
      @responses.select(&:valid?)
    end

    def invalid_responses
      @responses.reject(&:valid?)
    end

    def statistics
      lines = []

      lines << "Validated #{responses.size} pages.".yellow
      lines << "All pages are valid.".green if invalid_responses.size == 0
      lines << "#{x_pages_be(invalid_responses.size)} invalid.".red if invalid_responses.size > 0

      invalid_responses.each do |response|
        lines << "  #{response.uri}:".red

        response.errors.each do |error|
          lines << "    - #{error.to_s}".red
        end
      end

      lines.join("\n")
    end

    def x_pages_be(size)
      if size <= 1
        "#{size} page is"
      else
        "#{size} pages are"
      end
    end

    class Response
      attr_reader :uri

      def initialize(response = nil, uri = nil)
        @response = response
        @uri      = uri
      end

      def valid?
        @response.empty?
      end

      def errors
        @response.split("\n").map do |error|
          matches = error.match(/line (\d*) column (\d*) - (.*)/)
          Error.new( matches[1],
                     matches[3],
                     column: matches[2]
                   )
        end
      end

      class Error
        attr_reader :line, :message, :details

        def initialize(line, message, details = {})
          @line    = line
          @message = message
          @details = details
        end

        def to_s
          "Line #{@line}, column #{@details[:column]}: #{@message}."
        end
      end
    end
  end
end
