# encoding: utf-8

Gem::Specification.new do |s|
  s.name     = 'headhunter'
  s.version  = '0.0.1'
  s.authors  = ['Joshua Muheim']
  s.email    = 'josh@muheimwebdesign.ch'
  s.homepage = 'http://github.com/jmuheim/headhunter'
  s.summary  = 'An automatic HTML validator hooks into your request/acceptance/feature test suite and validates your HTML after every request'
  s.license  = 'MIT'

  s.add_dependency 'colorize'

  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'rake'

  s.files        = `git ls-files LICENSE README.md bin lib vendor`.split
  s.require_path = 'lib'
  s.executables  = Dir.glob('bin/*').map(&File.method(:basename))
end

