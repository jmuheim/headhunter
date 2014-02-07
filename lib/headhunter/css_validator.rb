require 'headhunter/local_response'
require 'net/http'

module Headhunter
  class CssValidator
    def validate(file)
      results = nil # Needed?

      Dir.chdir(Gem.loaded_specs['headhunter'].full_gem_path + '/lib/css-validator/') do
        # See http://stackoverflow.com/questions/1137884/is-there-an-open-source-css-validator-that-can-be-run-locally
        # More config options see http://jigsaw.w3.org/css-validator/manual.html
        if File.exists?(file)
          results = `java -jar css-validator.jar --output=soap12 file:#{file}`
        else
          raise "Couldn't locate file #{file}"
        end
      end

      LocalResponse.new(results)
    end

    def initialize(stylesheets = [], profile = 'css3', vextwarning = true)
      @stylesheets = stylesheets
      @profile     = profile     # TODO!
      @vextwarning = vextwarning # TODO!

      @messages_per_stylesheet = {}
    end

    def process!
      @stylesheets.each do |stylesheet|
        response = validate(stylesheet)

        unless response.valid?
          process_errors(response)
        end
      end
    end

    def process_errors(response)
      @messages_per_stylesheet[response.file] = []

      response.errors.each do |error|
        @messages_per_stylesheet[response.file] << "Line #{error[:line]}: #{error[:message]}"
      end
    end

    def report
      puts "Validated #{@stylesheets.size} stylesheets.".yellow
      puts "#{x_stylesheets_be(@stylesheets.size - @messages_per_stylesheet.size)} valid.".green if @messages_per_stylesheet.size < @stylesheets.size
      puts "#{x_stylesheets_be(@messages_per_stylesheet.size)} invalid.".red if @messages_per_stylesheet.size > 0

      @messages_per_stylesheet.each_pair do |stylesheet, messages|
        puts "  #{extract_filename(stylesheet)}:".red

        messages.each { |message| puts "  - #{message}".red }
      end

      puts
    end

    private

    # Converts a path like #{Rails.root}/public/assets/application-d205d6f344d8623ca0323cb6f6bd7ca1.css to application.css
    def extract_filename(path)
      if matches = path.match(/public\/assets\/([a-z\-_]*)-([a-z0-9]*)(\.css)$/)
        matches[1] + matches[3]
      else
        raise "Unexpected path: #{path}"
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
