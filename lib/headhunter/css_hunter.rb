require 'css_parser'
require 'nokogiri'

module Headhunter
  class CssHunter
    attr_reader :unused_selectors, :used_selectors, :error_selectors

    def initialize(stylesheets = [])
      @stylesheets      = stylesheets
      @parsed_rules     = {}
      @unused_selectors = []
      @used_selectors   = []
      @error_selectors  = []

      load_css
    end

    def process!(url, html)
      detect_used_selectors_in(Nokogiri::HTML(html)).each do |selector|
        @used_selectors << selector
        @unused_selectors.delete(selector)
      end
    end

    def statistics
      lines = []

      lines << "Found #{used_selectors.size + unused_selectors.size + error_selectors.size} CSS selectors.".yellow
      lines << 'All selectors are in use.'.green if unused_selectors.size + error_selectors.size == 0
      lines << "#{unused_selectors.size} selectors are not in use: #{unused_selectors.sort.join(', ').red}".red if unused_selectors.size > 0
      lines << "#{error_selectors.size} selectors could not be parsed: #{error_selectors.sort.join(', ').red}".red if error_selectors.size > 0

      lines.join("\n")
    end

    private

    def detect_used_selectors_in(document)
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

    def load_css
      @stylesheets.each do |stylesheet|
        add_css_selectors_from(IO.read(stylesheet))
      end
    end

    def add_css_selectors_from(css)
      parser = CssParser::Parser.new
      parser.add_block!(css)

      selector_count = 0

      parser.each_selector do |selector, declarations, specificity|
        next if @unused_selectors.include?(selector)
        next if selector =~ @ignore_selectors
        next if has_pseudo_classes(selector) and @unused_selectors.include?(bare_selector_from(selector))

        @unused_selectors << selector
        @parsed_rules[selector] = declarations

        selector_count += 1
      end

      selector_count
    end

    def has_pseudo_classes(selector)
      selector =~ /::?[\w\-]+/
    end

    def bare_selector_from(selector)
      selector = remove_at_rules_from(selector)
      selector = remove_pseudo_classes_from(selector)
    end

    def remove_at_rules_from(selector)
      selector.gsub(/^@.*/, '') # @keyframes
    end

    def remove_pseudo_classes_from(selector)
      selector.gsub(/:.*/, '')  # input#x:nth-child(2):not(#z.o[type='file'])
    end
  end

  class FetchError < StandardError; end
end
