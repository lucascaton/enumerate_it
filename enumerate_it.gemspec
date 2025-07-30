$LOAD_PATH << File.expand_path('lib', __dir__)
require 'enumerate_it/version'

Gem::Specification.new do |gem|
  gem.authors       = ['Cássio Marques', 'Lucas Caton']
  gem.summary       = 'Ruby Enumerations'
  gem.description   = 'Enumerations for Ruby with some magic powers!'
  gem.homepage      = 'https://github.com/lucascaton/enumerate_it'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split("\n")
  gem.name          = 'enumerate_it'
  gem.require_paths = ['lib']
  gem.version       = EnumerateIt::VERSION
  gem.required_ruby_version = '>= 3.0.0'

  gem.metadata = {
    'source_code_uri' => 'https://github.com/lucascaton/enumerate_it',
    'changelog_uri' => 'https://github.com/lucascaton/enumerate_it/releases',
    'rubygems_mfa_required' => 'true'
  }

  gem.add_dependency 'activesupport', '>= 6.0.0'

  gem.add_development_dependency 'activerecord'
  gem.add_development_dependency 'appraisal'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-rake'
  gem.add_development_dependency 'rubocop-rspec'
  gem.add_development_dependency 'sqlite3'
end
