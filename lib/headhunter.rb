require 'headhunter/rails'
require 'headhunter/css_hunter'
require 'headhunter/html_hunter'
require 'rack/utils'

class Headhunter
  attr_accessor :results

  def initialize(root)
    @html_hunter = HtmlHunter.new
    @css_hunter  = CssHunter.new(root)
  end

  def process!(url, html)
    @html_hunter.process!(url, html)
    @css_hunter.process!(url, html)
  end

  def clean_up!
    @css_hunter.clean_up!
  end

  def report
    @html_hunter.prepare_results_html

    @html_hunter.report
    @css_hunter.report
  end
end
