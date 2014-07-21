if ENV['HEADHUNTER'] == 'true' || ENV['RAILS_ENV'] == 'test'
  require 'headhunter/engine'
  require 'headhunter/css_hunter'
  require 'headhunter/css_validator'
  require 'headhunter/html_validator'
  require 'headhunter/rails'
  require 'headhunter/runners/runner'
  require 'headhunter/runners/html_runner'
  require 'headhunter/runners/css_runner'
end

module Headhunter
end
