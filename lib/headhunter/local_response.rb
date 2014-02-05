require 'nokogiri/xml'

module Headhunter
  class LocalResponse
    attr_reader :body

    def initialize(body)
      @body = Nokogiri::XML(body)
      @headers = {'x-w3c-validator-status' => valid?}
    end

    def [](key)
      @headers[key]
    end

    def valid?
      @body.css('validity') == 'true'
    end

    def errors
      @body.css('errors error').map do |error|
        { line: error.css('line').text.strip.to_i,
          errortype: error.css('errortype').text.strip,
          context: error.css('context').text.strip,
          errorsubtype: error.css('errorsubtype').text.strip,
          skippedstring: error.css('skippedstring').text.strip,
          message: error.css('message').text.strip[0..-3]
        }
      end
    end
  end
end