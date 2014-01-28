require 'rexml/document'

module Headhunter
  class LocalResponse
    attr_reader :body

    def initialize(body)
      @body = body
      @headers = {'x-w3c-validator-status' => valid?}
    end

    def [](key)
      @headers[key]
    end

    def valid?
      REXML::Document.new(@body).root.each_element('//m:validity') { |e| return e.text == 'true' }
    end
  end
end