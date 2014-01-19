require 'css_parser'
require 'nokogiri'
require 'open-uri'

class Headhunter
  class CssHunter
    def initialize(root)
      @root             = root
      @stylesheets      = []
      @parsed_rules     = {}
      @unused_selectors = []
      @used_selectors   = []

      load_css!
    end

    def process!(url, html)
      analyze(html).each do |selector|
        @unused_selectors.delete(selector)
      end
    end

    def report
      log.puts "Found #{@used_selectors.size + @unused_selectors.size} CSS selectors.".yellow
      log.puts "#{@used_selectors.size} selectors are in use.".green if @used_selectors.size > 0
      log.puts "#{@unused_selectors.size} selectors are not in use: #{@unused_selectors.sort.join(', ').red}".red if @unused_selectors.size > 0
      log.puts
    end

    def clean_up!
      remove_assets!
    end

    private

    def analyze(html)
      doc = Nokogiri::HTML(html)

      @unused_selectors.collect do |selector, declarations|
        # We test against the selector stripped of any pseudo classes,
        # but we report on the selector with its pseudo classes.
        stripped_selector = strip(selector)

        next if stripped_selector.empty?

        if doc.search(stripped_selector).any?
          @used_selectors << selector
          selector
        end
      end
    end

    def load_css!
      precompile_assets!
      @stylesheets += Dir.chdir(@root) { Dir.glob("public/assets/*.css") }

      @stylesheets.each do |path|
        new_selector_count = add_css!(fetch(path))
      end
    end

    def fetch(path)
      log.puts(path)

      loc = "#{@root}/#{path}"

      begin
        open(loc).read
      rescue Errno::ENOENT
        raise FetchError.new("#{loc} was not found")
      rescue OpenURI::HTTPError => e
        raise FetchError.new("retrieving #{loc} raised an HTTP error: #{e.message}")
      end
    end

    def add_css!(css)
      parser = CssParser::Parser.new
      parser.add_block!(css)

      selector_count = 0

      parser.each_selector do |selector, declarations, specificity|
        next if @unused_selectors.include?(selector)
        next if selector =~ @ignore_selectors
        next if has_pseudo_classes(selector) and @unused_selectors.include?(strip(selector))

        @unused_selectors << selector
        @parsed_rules[selector] = declarations

        selector_count += 1
      end

      selector_count
    end

    def has_pseudo_classes(selector)
      selector =~ /::?[\w\-]+/
    end

    def strip(selector)
      selector = selector.gsub(/^@.*/, '') # @-webkit-keyframes ...
      selector = selector.gsub(/:.*/, '')  # input#x:nth-child(2):not(#z.o[type='file'])
      selector
    end

    # TODO: suppress logging output of rake tasks!
    def precompile_assets!
      system "rake assets:clobber HEADHUNTER=false &> /dev/null" # Remove existing assets! This seems to be necessary to make sure that they don't exist twice, see http://stackoverflow.com/questions/20938891
      system "rake assets:precompile HEADHUNTER=false &> /dev/null"
    end

    def remove_assets!
      system "rake assets:clobber HEADHUNTER=false &> /dev/null"
    end
  end

  class FetchError < StandardError; end
end
