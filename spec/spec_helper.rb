ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'pry'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
end

def path_to_file(name)
  File.join(File.dirname(__FILE__), 'files', name)
end

def read_file(name)
  File.read(path_to_file(name))
end