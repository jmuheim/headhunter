$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require 'headhunter/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'headhunter'
  s.version     = Headhunter::VERSION
  s.authors     = ['Joshua Muheim']
  s.email       = 'josh@muheimwebdesign.ch'
  s.homepage    = 'http://github.com/jmuheim/headhunter'
  s.summary     = 'Zero config HTML & CSS validation tool for Rails apps'
  s.description = 'Headhunter is an HTML and CSS validation tool that injects itself into your Rails feature tests and automagically checks all your generated HTML and CSS for validity. In addition, it also looks out for unused (and therefore superfluous) CSS selectors.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails'
  s.add_dependency 'css_parser', '>= 1.2.6'
  s.add_dependency 'colorize'
  s.add_dependency 'nokogiri'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'

  s.test_files = Dir['spec/**/*']
end
