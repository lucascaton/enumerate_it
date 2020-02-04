$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'enumerate_it'

require 'active_support/all'
require 'active_record'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

I18n.config.enforce_available_locales = false
I18n.load_path = Dir['spec/i18n/*.yml']

RSpec.configure do |config|
  config.filter_run_when_matching :focus

  config.before(:each, sqlite: true) do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  end
end
