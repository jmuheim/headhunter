require 'net/http'
require 'rexml/document'

class Headhunter
  class CssValidator
    def initialize(stylesheets)
      @profile = 'css3' # TODO: Option for profile css1 and css21
      @stylesheets = stylesheets
      @messages_per_stylesheet = {}
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
      log.puts "Validated #{@stylesheets.size} stylesheets.".yellow
      log.puts "#{x_stylesheets_be(@stylesheets.size - @messages_per_stylesheet.size)} valid.".green if @messages_per_stylesheet.size < @stylesheets.size
      log.puts "#{x_stylesheets_be(@messages_per_stylesheet.size)} invalid.".red if @messages_per_stylesheet.size > 0

      @messages_per_stylesheet.each_pair do |stylesheet, messages|
        log.puts "  #{extract_filename(stylesheet)}:".red

        messages.each { |message| log.puts "  - #{message}".red }
      end
    end

    private

    def extract_filename(path)
      binding.pry
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

      REXML::Document.new(response.body).root.each_element('//m:error') do |e|
        @messages_per_stylesheet[file] << "#{error_line_prefix}: line #{e.elements['m:line'].text}: #{e.elements['m:message'].get_text.value.strip}\n"
      end
    end

    def fetch(path) # TODO: Move to Headhunter!
      log.puts(path)

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
      get_validator_response(query_params)
    end

    def response_indicates_valid?(response)
      response['x-w3c-validator-status'] == 'Valid'
    end

    def get_validator_response(query_params = {})
      response = call_validator(query_params)

      raise "HTTP error: #{response.code}" unless response.is_a? Net::HTTPSuccess
      return response
    end

    def call_validator(query_params)
      boundary = Digest::MD5.hexdigest(Time.now.to_s)
      data = encode_multipart_params(boundary, query_params)
      return http_start(validator_host).post2(validator_path, data, "Content-type" => "multipart/form-data; boundary=#{boundary}" )
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
