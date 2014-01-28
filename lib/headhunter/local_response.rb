require 'rexml/document'

module Headhunter
  class LocalResponse
    attr_reader :body

    def initialize(body)
      @body     = body
      @document = REXML::Document.new(@body)
      @headers  = {'x-w3c-validator-status' => valid?}
    end

    def [](key)
      @headers[key]
    end

    def valid?
      @document.root.each_element('//m:validity') { |e| return e.text == 'true' }
    end

    def errors
      binding.pry
      @document.root.each_element('//m:error').inject([]) do |memo, error|
        memo << {line:    extract_line_from_error(error),
                 message: extract_message_from_error(error)}
      end
    end

    private

    def extract_line_from_error(error)
      error.elements['m:line'].text
    end

    def extract_message_from_error(error)
      error.elements['m:message'].get_text.value.strip[0..-2]
    end
  end
end