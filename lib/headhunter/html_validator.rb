require 'open3'
require 'colorize'

module Headhunter
  class HtmlValidator
    VALIDATOR_DIR = File.join Gem.loaded_specs['headhunter'].full_gem_path, '/lib/tidy'
    EXECUTABLE    = 'tidy'

    attr_reader :responses

    def initialize
      @responses = []
    end

    def validate(uri, html)
      tidy_path = %x[which #{EXECUTABLE}].strip
      tidy_path = File.join(VALIDATOR_DIR, EXECUTABLE) unless tidy_path.present?

      fail "Could not find #{tidy_path}" unless File.exist? tidy_path

      # tidy_version = `#{executable} -v`
      # puts "Using #{executable}: #{tidy_version}"

      # Docs for Tidy: http://tidy.sourceforge.net/docs/quickref.html

      begin
        stdin, stdout, stderr = Open3.popen3("#{tidy_path} -quiet")
        stdin.puts html
        stdin.close
        stdout.close

        @responses << Response.new(stderr.read, uri)
        stderr.close
      rescue Encoding::UndefinedConversionError
        # not HTML, maybe something else (PDF, image, ...)
      end
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
      lines << "All pages are valid.".green unless invalid_responses.any?
      lines << "#{x_pages_be(invalid_responses.size)} invalid.".red if invalid_responses.any?

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
