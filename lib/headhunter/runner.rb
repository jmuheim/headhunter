require 'fileutils'

module Headhunter
  class Runner
    ASSETS_PATH = 'public/assets'

    attr_accessor :results

    def initialize(root)
      @root             = root
      @temporary_assets = []

      precompile_assets!

      @html_validator = HtmlValidator.new
      @css_hunter     = CssHunter.new(stylesheets)

      @css_validator = CssValidator.new(stylesheets)
      @css_validator.process!
    end

    def process!(url, html)
      @html_validator.process!(url, html)
      @css_hunter.process!(url, html)
    end

    def clean_up!
      puts "Headhunter is removing precompiled assets..."
      remove_assets!
      puts " done!".yellow
    end

    def report
      @html_validator.prepare_results_html

      @html_validator.report
      @css_validator.report
      @css_hunter.report
    end

    private

    def precompile_assets!
      puts "Headhunter is removing eventually existing assets..."
      remove_assets! # Remove existing assets! This seems to be necessary to make sure that they don't exist twice, see http://stackoverflow.com/questions/20938891
      sleep 1
      puts " done!"

      sleep 1

      puts "Headhunter is precompiling assets..."
      system 'rake assets:precompile HEADHUNTER=false &> /dev/null'
      puts " done!"
    end

    def remove_assets!
      FileUtils.rm_r ASSETS_PATH if File.exist?(ASSETS_PATH)
    end

    def stylesheets
      Dir["#{ASSETS_PATH}/*.css"]
    end
  end
end
