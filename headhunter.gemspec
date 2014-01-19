# encoding: utf-8

Gem::Specification.new do |s|
  s.name     = 'headhunter'
  s.version  = '0.0.1'
  s.authors  = ['Joshua Muheim']
  s.email    = 'josh@muheimwebdesign.ch'
  s.homepage = 'http://github.com/jmuheim/headhunter'
  s.summary  = 'An automatic HTML validator hooks into your request/acceptance/feature test suite and validates your HTML after every request'
  s.license  = 'MIT'

  s.add_dependency 'html_validation'
  s.add_dependency 'colorize'
end

