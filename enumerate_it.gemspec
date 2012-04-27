# -*- encoding: utf-8 -*-
require File.expand_path('../lib/enumerate_it/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Cássio Marques"]
  gem.email         = ["cassiommc@gmail.com"]
  gem.description   = %q{Have a legacy database and need some enumerations in your models to match those stupid '4 rows/2 columns' tables with foreign keys and stop doing joins just to fetch a simple description? Or maybe use some integers instead of strings as the code for each value of your enumerations? Here's EnumerateIt.}
  gem.summary       = %q{Ruby Enumerations}
  gem.homepage      = "http://github.com/cassiomarques/enumerate_it"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "enumerate_it"
  gem.require_paths = ["lib"]
  gem.version       = EnumerateIt::VERSION

  gem.add_dependency "activesupport", ">= 2.3.2"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", ">= 2.5.0"
  gem.add_development_dependency "activerecord", ">= 3.0.5"
end
