lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bandsintown'

Gem::Specification.new do |s|
  s.name          = 'bandsintown'
  s.summary       = 'Wrapper for bandsintown API'
  s.authors       = ['mcostanza']
  s.version       = Bandsintown::VERSION
  s.date          = '2014-12-14'
  s.files         = `git ls-files lib -z`.split("\x0")
  s.require_paths = ['lib']

  s.add_dependency 'bundler'
  s.add_dependency 'rest-client'
  s.add_dependency 'activesupport'
  s.add_development_dependency 'rspec'
end
