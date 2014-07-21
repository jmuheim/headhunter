module Headhunter
  class CssRunner
    ASSETS_PATH = 'public/assets'

    def initialize
      precompile_assets!
      @css_hunter     = CssHunter.new(stylesheets)
      @css_validator = CssValidator.new(stylesheets)
    end

    def process(url, html)
      @css_hunter.process(html)
      # TODO: maybe we should call @css_validator.validate(html) ?
    end

    def results
      [
        @css_hunter.statistics,
        @css_validator.statistics,
      ]
    end

    def clean_up
      print "Headhunter is removing precompiled assets...".yellow
      remove_assets!
      puts " done!".yellow
    end

    private

    def stylesheets
      Dir["#{::Rails.root}/#{ASSETS_PATH}/*.css"]
    end

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
  end
end
