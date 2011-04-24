# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name = %q{enumerate_it}
  s.version     = EnumerateIt::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["C\303\241ssio Marques"]
  s.description = %q{Have a legacy database and need some enumerations in your models to match those stupid '4 rows/2 columns' tables with foreign keys and stop doing joins just to fetch a simple description? Or maybe use some integers instead of strings as the code for each value of your enumerations? Here's EnumerateIt.}
  s.email = %q{cassiommc@gmail.com}
  s.homepage = %q{http://github.com/cassiomarques/enumerate_it}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby Enumerations}
  s.test_files = [
    "spec/enumerate_it_spec.rb",
    "spec/spec_helper.rb"
  ]

  s.add_development_dependency "rspec", "=2.5.0"
  s.add_development_dependency "activerecord", "=3.0.5"

  s.add_dependency "activesupport", ">=2.3.2"
end

