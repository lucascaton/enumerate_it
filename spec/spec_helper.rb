$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'enumerate_it'
require 'rspec'
require 'rspec/autorun'

require 'rubygems'
require "active_support"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/string/inflections"
require 'active_support/core_ext/object/to_json'

I18n.load_path = Dir['spec/i18n/*.yml']
