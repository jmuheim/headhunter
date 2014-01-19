require 'headhunter/rails'
require 'html_validation'
require 'rack/utils'

class Result
  attr_accessor :url, :html, :results

  def initialize(url, html, results)
    @url     = url
    @html    = html
    @results = results
  end
end

class Headhunter
  attr_accessor :results

  def initialize
    @valid_results   = []
    @invalid_results = []
    # yield self and run if block_given?
  end

  def process!(url, html)
    if is_valid_asset?(html)
      @valid_results << Result.new(url, html, 'alles gut!')
    else
      @invalid_results << Result.new(url, html, 'nichts gut!')
    end
  end

  def is_valid_asset?(html)
    true
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
