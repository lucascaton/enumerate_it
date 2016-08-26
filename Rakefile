# encoding: utf-8

require 'bundler/gem_tasks'

if ENV['APPRAISAL_INITIALIZED'] || ENV['TRAVIS'] || RUBY_VERSION < '2.0.0'
  require 'rspec/core/rake_task'

  Bundler::GemHelper.install_tasks
  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
else
  require 'appraisal'

  task default: :appraisal
end
