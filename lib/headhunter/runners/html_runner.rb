module Headhunter
  class HtmlRunner
    def initialize
      @html_validator = HtmlValidator.new
    end

    def process(url, html)
      @html_validator.validate(url, html)
    end

    def results
      @html_validator.statistics
    end

    def clean_up ; end
  end
end
