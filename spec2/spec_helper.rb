require 'rubygems'
require 'rspec'

begin
  require 'ruby-debug'
rescue LoadError
end

$: << File.join(File.dirname(__FILE__), %w(.. lib))

require 'headhunter'

RSpec.configure do |config|
  config.include Headhunter
end
