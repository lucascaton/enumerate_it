$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'enumerate_it'

require 'active_support/all'
require 'active_record'

Dir['./spec/support/**/*.rb'].each { |f| require f }

I18n.config.enforce_available_locales = false
I18n.load_path = Dir['spec/i18n/*.yml']

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
