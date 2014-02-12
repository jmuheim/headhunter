require 'html_validation'

module Headhunter
  class HtmlValidator
    attr_reader :responses

    def initialize
      @responses = []
    end

    def validate(url, html)
      # Docs for Tidy: http://tidy.sourceforge.net/docs/quickref.html
      @responses << PageValidations::HTMLValidation.new.validation(html, url)
      @responses.last
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
      lines << "All pages are valid.".green if invalid_responses.size == 0
      lines << "#{x_pages_be(invalid_responses.size)} invalid.".red if invalid_responses.size > 0

      invalid_responses.each do |response|
        lines << "  #{response.resource}:".red
      
        ([response.exceptions].flatten).each do |exception|
          lines << "    - #{exception.strip}".red
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
  end
end
