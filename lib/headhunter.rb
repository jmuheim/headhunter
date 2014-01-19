require 'headhunter/rails'
require 'html_validation'
require 'rack/utils'

class Headhunter
  attr_accessor :results

  class HtmlHunter
    def initialize
      @valid_results   = []
      @invalid_results = []
    end

    def process!(url, html)
      html_validation = PageValidations::HTMLValidation.new.validation(html, random_name)
      (html_validation.valid? ? @valid_results : @invalid_results) << html_validation
    end

    def prepare_results_html
      html = File.read File.dirname(File.expand_path(__FILE__)) + '/headhunter/templates/results.html'
      html.gsub! '{{VALID_RESULTS}}', prepare_results_for(@valid_results)
      html.gsub! '{{INVALID_RESULTS}}', prepare_results_for(@invalid_results)
      File.open('.validation/results.html', 'w') { |file| file.write(html) }
    end

    def prepare_results_for(results)
      results.map do |result|
        exceptions_html = ::Rack::Utils.escape_html(File.read(".validation/#{result.resource}.exceptions.txt"))

        full_result_html = File.read File.dirname(File.expand_path(__FILE__)) + '/headhunter/templates/result.html'
        full_result_html.gsub! '{{RESOURCE}}', result.resource
        full_result_html.gsub! '{{EXCEPTIONS}}', exceptions_html
        full_result_html.gsub! '{{HTML_CONTEXT}}', 'context'
        full_result_html.gsub! '{{LINK}}', "#{result.resource}.html.txt"

        full_result_html
      end.join
    end

    def report
      log.puts "Validated #{@valid_results.size + @invalid_results.size} HTML pages.".yellow
      log.puts "#{x_pages_be(@valid_results.size)} valid.".green
      log.puts "#{x_pages_be(@invalid_results.size)} invalid.".red
      log.puts 'Open .validation/results.html to view full results.'
    end

    private

    def x_pages_be(size)
      if size <= 1
        "#{size} page is"
      else
        "#{size} pages are"
      end
    end

    def random_name
      (0...8).map { (65 + rand(26)).chr }.join
    end
  end

  class CssHunter
    def initialize
    end

    def process!(url, html)
      
    end

    def report
      
    end
  end

  def initialize
    @html_hunter = HtmlHunter.new
    @css_hunter  = CssHunter.new
  end

  def process!(url, html)
    @html_hunter.process!(url, html)
    @css_hunter.process!(url, html)
  end

  def report
    @html_hunter.prepare_results_html

    @html_hunter.report
    @css_hunter.report
  end
end
