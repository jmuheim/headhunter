require 'open3'
require 'colorize'
require 'net/http'
require 'nokogiri/xml'

module Headhunter
  class CssValidator
    VALIDATOR_DIR = Gem.loaded_specs['headhunter'].full_gem_path + '/lib/css-validator/'

    attr_reader :stylesheets, :responses

    def initialize(stylesheets = [], profile = 'css3', vextwarning = true)
      @stylesheets = stylesheets
      @profile     = profile     # TODO!
      @vextwarning = vextwarning # TODO!

      @responses = []

      @stylesheets.map do |stylesheet|
        validate(stylesheet)
      end
    end

    def validate(uri)
      Dir.chdir(VALIDATOR_DIR) do
        raise "Couldn't locate uri #{uri}" unless File.exists? uri

        # See http://stackoverflow.com/questions/1137884/is-there-an-open-source-css-validator-that-can-be-run-locally
        # More config options see http://jigsaw.w3.org/css-validator/manual.html
        stdin, stdout, stderr = Open3.popen3("java -jar css-validator.jar --output=soap12 file:#{uri}")
        stdin.close
        stderr.close

        @responses << Response.new(stdout.read)
        stdout.close
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

      lines << "Validated #{responses.size} stylesheets.".yellow
      lines << "All stylesheets are valid.".green unless invalid_responses.any?
      lines << "#{x_stylesheets_be(invalid_responses.size)} invalid.".red if invalid_responses.any?

      invalid_responses.each do |response|
        lines << "  #{extract_filename(response.uri)}:".red

        response.errors.each do |error|
          lines << "    - #{error.to_s}".red
        end
      end

      lines.join("\n")
    end

    def extract_filename(path)
      if matches = path.match(/public\/assets\/([a-z\-_]*)-([a-z0-9]{32})(\.css)$/)
        matches[1] + matches[3] # application-d205d6f344d8623ca0323cb6f6bd7ca1.css becomes application.css
      else
        File.basename(path)
      end
    end

    def x_stylesheets_be(size)
      if size <= 1
        "#{size} stylesheet is"
      else
        "#{size} stylesheets are"
      end
    end

    class Response
      def initialize(response = nil)
        @dom = Nokogiri::XML(convert_soap_to_xml(response)) if response
      end

      def [](key)
        @dom[key] # TODO: still needed?
      end

      def valid?
        @dom.css('validity').text == 'true'
      end

      def errors
        @dom.css('errors error').map do |error|
          Error.new( error.css('line').text.strip.to_i,
                     error.css('message').text.strip[0..-3],
                     errortype: error.css('errortype').text.strip,
                     context: error.css('context').text.strip,
                     errorsubtype: error.css('errorsubtype').text.strip,
                     skippedstring: error.css('skippedstring').text.strip
                   )
        end
      end

      def uri
        @dom.css('cssvalidationresponse > uri').text
      end

      private

      def convert_soap_to_xml(soap)
        sanitize_prefixed_tags_from(
          remove_first_line_from(soap)
        )
      end

      # The first line of the validator's response contains parameter options like this:
      #
      #     {vextwarning=false, output=soap, lang=en, warning=2, medium=all, profile=css3}
      #
      # We remove this so Nokogiri can parse the document as XML.
      def remove_first_line_from(soap)
        soap.split("\n")[1..-1].join("\n")
      end

      # The validator's response contains strange SOAP tags like `m:error` or `env:body` which need to be sanitized for Nokogiri.
      #
      # We simply remove the `m:` and `env:` prefixes from the source, so e.g. `<env:body>` becomes `<body>`.
      def sanitize_prefixed_tags_from(soap)
        soap.gsub /(m|env):/, ''
      end

      class Error
        attr_reader :line, :message, :details

        def initialize(line, message, details = {})
          @line    = line
          @message = message
          @details = details
        end

        def to_s
          "Line #{@line}: #{@message}."
        end
      end
    end
  end
end
