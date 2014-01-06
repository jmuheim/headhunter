require 'headhunter/rake_task'

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
    log.puts "#{@valid_results.size} pages are valid.".green
    log.puts "#{@invalid_results.size} pages are invalid.".red
  end
end
