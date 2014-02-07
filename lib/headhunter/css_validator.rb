require 'headhunter/local_response'
require 'net/http'

module Headhunter
  class CssValidator
    VALIDATOR_PATH = Gem.loaded_specs['headhunter'].full_gem_path + '/lib/css-validator/'

    attr_reader :stylesheets

    def initialize(stylesheets = [], profile = 'css3', vextwarning = true)
      @stylesheets = stylesheets
      @profile     = profile     # TODO!
      @vextwarning = vextwarning # TODO!

      @responses = @stylesheets.map do |stylesheet|
                     validate(stylesheet)
                   end
    end

    def validate(file)
      # See http://stackoverflow.com/questions/1137884/is-there-an-open-source-css-validator-that-can-be-run-locally
      # More config options see http://jigsaw.w3.org/css-validator/manual.html
      results = if File.exists?(file)
                  Dir.chdir(VALIDATOR_PATH) { `java -jar css-validator.jar --output=soap12 file:#{file}` }
                else
                  raise "Couldn't locate file #{file}"
                end

      LocalResponse.new(results)
    end

    def valid_responses
      @responses.select(&:valid?)
    end

    def invalid_responses
      @responses.reject(&:valid?)
    end

    def statistics
      lines = []

      lines << "Validated #{stylesheets.size} stylesheets.".yellow
      lines << "#{x_stylesheets_be(stylesheets.size - invalid_responses.size)} valid.".green if valid_responses.size > 0
      lines << "#{x_stylesheets_be(invalid_responses.size)} invalid.".red if invalid_responses.size > 0

      invalid_responses.each do |response|
        lines << "  #{extract_filename(response.file)}:".red

        response.errors.each do |error|
          lines << "    - Line #{error[:line]}: #{error[:message]}.".red
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
  end
end
