# encoding: utf-8

require 'rspec/core/rake_task'
require 'appraisal'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

if ENV['APPRAISAL_INITIALIZED'] || ENV['TRAVIS']
  task default: :spec
else
  task default: :appraisal
end
