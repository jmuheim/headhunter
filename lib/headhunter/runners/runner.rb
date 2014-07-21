require 'fileutils'

module Headhunter
  class Runner
    attr_accessor :results

    def initialize(root)
      @root = root

      @runners = []
      @runners << HtmlRunner.new if (ENV['HEADHUNTER_HTML'] || 'true') == 'true'
      @runners << CssRunner.new if (ENV['HEADHUNTER_CSS'] || 'true') == 'true'
    end

    def process(url, html)
      @runners.each do |runner|
        runner.process(url, html)
      end
    end

    def clean_up!
      @runners.each do |runner|
        runner.clean_up
      end
    end

    def report
      puts @runners.map { |runner| runner.results }.compact.join "\n\n"
    end
  end
end
