$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'enumerate_it'
require 'base'
require 'spec'
require 'spec/autorun'

require 'rubygems'
require 'active_record'

I18n.load_path = Dir['spec/i18n/*.yml']
