$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'enumerate_it'
require 'rspec'

require 'rubygems'
require 'active_support/all'
require 'active_record'

Dir['./spec/support/**/*.rb'].each { |f| require f }

I18n.config.enforce_available_locales = false
I18n.load_path = Dir['spec/i18n/*.yml']
