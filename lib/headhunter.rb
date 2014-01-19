require 'headhunter/css_hunter'
require 'headhunter/css_validator'
require 'headhunter/html_validator'
require 'headhunter/rails'
# require 'rack/utils'

class Headhunter
  attr_accessor :results

  def initialize(root)
    @root = root

    precompile_assets!

    @html_validator = HtmlValidator.new
    @css_validator  = CssValidator.new(stylesheets)
    @css_hunter     = CssHunter.new(stylesheets)

    @css_validator.process!
  end

  def process!(url, html)
    @html_validator.process!(url, html)
    @css_hunter.process!(url, html)
  end

  def clean_up!
    remove_assets!
  end

  def report
    @html_validator.prepare_results_html

    @html_validator.report
    @css_validator.report
    @css_hunter.report
  end

  private

  def precompile_assets!
    # Remove existing assets! This seems to be necessary to make sure that they don't exist twice, see http://stackoverflow.com/questions/20938891
    system 'rake assets:clobber HEADHUNTER=false &> /dev/null'

    system 'rake assets:precompile HEADHUNTER=false &> /dev/null'
  end

  def remove_assets!
    system 'rake assets:clobber HEADHUNTER=false &> /dev/null'
  end

  def stylesheets
    Dir.chdir(@root) { Dir.glob('public/assets/*.css') }
  end
end
