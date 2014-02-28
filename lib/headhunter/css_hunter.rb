require 'css_parser'
require 'nokogiri'
require 'colorize'

module Headhunter
  class CssHunter
    attr_reader :unused_selectors, :used_selectors, :error_selectors

    def initialize(stylesheets = [])
      @stylesheets      = stylesheets
      @unused_selectors = []
      @used_selectors   = []
      @error_selectors  = []

      @stylesheets.each do |stylesheet|
        add_css_selectors_from(IO.read(stylesheet))
      end
    end

    def process(html)
      detect_used_selectors_in(html).each do |selector|
        @used_selectors << selector
        @unused_selectors.delete(selector)
      end
    end

    def statistics
      lines = "Found #{used_selectors.size + unused_selectors.size + error_selectors.size} CSS selectors.\n".yellow
      lines += "All selectors are in use.\n".green unless (unused_selectors + error_selectors).any?
      lines += "#{unused_selectors.size} selectors are not in use: #{unused_selectors.sort.join(', ')}\n".red if unused_selectors.any?
      lines +="#{error_selectors.size} selectors could not be parsed: #{error_selectors.sort.join(', ')}\n".red if error_selectors.any?
      lines
    end

    def detect_used_selectors_in(html)
      document = Nokogiri::HTML(html)

      @unused_selectors.collect do |selector, declarations|
        bare_selector = bare_selector_from(selector)

        begin
          selector if document.search(bare_selector).any?
        rescue Nokogiri::CSS::SyntaxError => e
          @error_selectors << selector
          @unused_selectors.delete(selector)
        end
      end.compact # FIXME: Why is compact needed?
    end

    def add_css_selectors_from(css)
      parser = CssParser::Parser.new
      parser.add_block!(css)

      parser.each_selector do |selector, declarations, specificity|
        # next if @unused_selectors.include?(selector)
        # next if has_pseudo_classes?(selector) and @unused_selectors.include?(bare_selector_from(selector))
        @unused_selectors << selector
      end
    end

    # def has_pseudo_classes?(selector)
    #   selector =~ /::?[\w\-]+/
    # end

    def bare_selector_from(selector)
      # Add more clean up stuff here, e.g. stuff like @keyframe (Deadweight implemented this)?
      remove_pseudo_classes_from(selector)
    end

    def remove_pseudo_classes_from(selector)
      selector.gsub(/:.*/, '')  # input#x:nth-child(2):not(#z.o[type='file'])
    end
  end
end
