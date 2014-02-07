require 'nokogiri/xml'

module Headhunter
  class LocalResponse
    def initialize(response = nil)
      @document = Nokogiri::XML(convert_soap_to_xml(response)) if response
    end

    def [](key)
      @headers[key]
    end

    def valid?
      @document.css('validity').text == 'true'
    end

    def errors
      @document.css('errors error').map do |error|
        { line:          error.css('line').text.strip.to_i,
          errortype:     error.css('errortype').text.strip,
          context:       error.css('context').text.strip,
          errorsubtype:  error.css('errorsubtype').text.strip,
          skippedstring: error.css('skippedstring').text.strip,
          message:       error.css('message').text.strip[0..-3]
        }
      end
    end

    def file
      @document.css('errorlist uri').text
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
  end
end