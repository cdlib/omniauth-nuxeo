require "date"
require File.expand_path("../lib/omniauth/nuxeo/version", __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Brian Riley"]
  s.email         = ["brian.riley@ucop.edu"]
  s.name          = "omniauth-nuxeo"
  s.homepage      = "https://github.com/cdlib/omniauth-nuxeo"
  s.summary       = "Nuxeo OAuth 2.0 Strategy for OmniAuth 1.5"
  s.date          = Date.today
  s.description   = "Enables third-party client apps to connect to the Nuxeo API"
  s.require_paths = ["lib"]
  s.version       = OmniAuth::Nuxeo::VERSION
  s.extra_rdoc_files = ["README.md"]
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  # Declary dependencies here, rather than in the Gemfile
  s.add_dependency 'omniauth-oauth2', '~> 1.3'
  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rack-test', '~> 0.6.3'
  s.add_development_dependency 'webmock', '~> 3.0', '>= 3.0.1'
end
