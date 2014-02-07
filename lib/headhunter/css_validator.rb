require 'headhunter/local_response'
require 'net/http'

module Headhunter
  class CssValidator
    class Validator
      def self.validate_file(path_to_file)
        string = fetch_file_content(path_to_file)
        validate_string(string)
      end

      def self.validate_string(string)
        get_local_validator_response(string)
      end

      def self.get_local_validator_response(string)
        path         = Gem.loaded_specs['headhunter'].full_gem_path + '/lib/css-validator/'
        css_file     = 'tmp.css'
        results_file = 'results'
        results      = nil

        Dir.chdir(path) do
          File.open(css_file, 'a') { |f| f.write string }

          # See http://stackoverflow.com/questions/1137884/is-there-an-open-source-css-validator-that-can-be-run-locally
          # More config options see http://jigsaw.w3.org/css-validator/manual.html
          if system "java -jar css-validator.jar --output=soap12 file:#{css_file} > #{results_file}"
            results = IO.read results_file
          else
            raise 'Could not execute local validation!'
          end

          File.delete css_file
          File.delete results_file
        end

        LocalResponse.new(results)
      end

      def self.fetch_file_content(path_to_file)
        IO.read(path_to_file)
      end
    end

    USE_LOCAL_VALIDATOR = true

    def initialize(stylesheets = [])
      @profile = 'css3' # TODO: Option for profile css1 and css21
      @stylesheets = stylesheets
      @messages_per_stylesheet = {}
    end

    def add_stylesheet(stylesheet)
      @stylesheets << stylesheet
    end

    def process!
      @stylesheets.each do |stylesheet|
        css = fetch(stylesheet)
        css = ' ' if css.empty? # The validator returns a 500 error if it receives an empty string

        response = get_validation_response({text: css, profile: @profile, vextwarning: 'true'})
        unless response_indicates_valid?(response)
          process_errors(stylesheet, css, response)
        end
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

    # Converts a path like public/assets/application-d205d6f344d8623ca0323cb6f6bd7ca1.css to application.css
    def extract_filename(path)
      if matches = path.match(/^public\/assets\/(.*)-?([a-z0-9]*)(\.css)/)
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

    def process_errors(file, css, response)
      @messages_per_stylesheet[file] = []

      response.errors.each do |error|
        @messages_per_stylesheet[file] << "Line #{error[:line]}: #{error[:message]}"
      end
    end

    def fetch(path) # TODO: Move to Headhunter!
      loc = path

      begin
        open(loc).read
      rescue Errno::ENOENT
        raise FetchError.new("#{loc} was not found")
      rescue OpenURI::HTTPError => e
        raise FetchError.new("retrieving #{loc} raised an HTTP error: #{e.message}")
      end
    end

    def get_validation_response(query_params)
      query_params.merge!({:output => 'soap12'})

      if USE_LOCAL_VALIDATOR
        call_local_validator(query_params)
      else
        call_remote_validator(query_params)
      end
    end

    def call_local_validator(query_params)
      Validator.validate_string query_params[:text]
    end

    def response_indicates_valid?(response)
      response['x-w3c-validator-status'] == 'Valid'
    end

    def call_remote_validator(query_params = {})
      boundary = Digest::MD5.hexdigest(Time.now.to_s)
      data = encode_multipart_params(boundary, query_params)
      response = http_start(validator_host).post2(validator_path,
                                                  data,
                                                  'Content-type' => "multipart/form-data; boundary=#{boundary}")

      raise "HTTP error: #{response.code}" unless response.is_a? Net::HTTPSuccess
      response
    end

    def encode_multipart_params(boundary, params = {})
      ret = ''
      params.each do |k,v|
        unless v.empty?
          ret << "\r\n--#{boundary}\r\n"
          ret << "Content-Disposition: form-data; name=\"#{k.to_s}\"\r\n\r\n"
          ret << v
        end
      end
      ret << "\r\n--#{boundary}--\r\n"
      ret
    end

    def http_start(host)
      if ENV['http_proxy']
        uri = URI.parse(ENV['http_proxy'])
        proxy_user, proxy_pass = uri.userinfo.split(/:/) if uri.userinfo
        Net::HTTP.start(host, nil, uri.host, uri.port, proxy_user, proxy_pass)
      else
        Net::HTTP.start(host)
      end
    end

    def validator_host
      'jigsaw.w3.org'
    end

    def validator_path
      '/css-validator/validator'
    end

    def error_line_prefix
      'Invalid css'
    end
  end
end
