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
    end

    def process!(url, html)
      @html_validator.validate(url, html)
      @css_hunter.process!(url, html)
    end

    def clean_up!
      print "Headhunter is removing precompiled assets...".yellow
      remove_assets!
      puts " done!".yellow
    end

    def report
      puts [ @html_validator.statistics,
             @css_validator.statistics,
             @css_hunter.statistics
           ].join "\n\n"

     puts
    end

    private

    def precompile_assets!
      print "Headhunter is removing eventually existing assets...".yellow
      remove_assets! # Remove existing assets! This seems to be necessary to make sure that they don't exist twice, see http://stackoverflow.com/questions/20938891
      sleep 1
      puts " done!".yellow

      sleep 1

      print "Headhunter is precompiling assets...".yellow
      system 'rake assets:precompile HEADHUNTER=false &> /dev/null'
      puts " done!\n".yellow
    end

    def remove_assets!
      FileUtils.rm_r ASSETS_PATH if File.exist?(ASSETS_PATH)
    end

    def stylesheets
      Dir["#{::Rails.root}/#{ASSETS_PATH}/*.css"]
    end
  end
end
