$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'enumerate_it'

require 'logger' # Required by Rails 7.0 or older - https://stackoverflow.com/a/79385484/1445184
require 'active_support/all'
require 'active_record'

Dir['./spec/support/**/*.rb'].each { |f| require f }

I18n.config.enforce_available_locales = false
I18n.load_path = Dir['spec/i18n/*.yml']

RSpec.configure do |config|
  config.filter_run_when_matching :focus

  config.before(:each, :sqlite) do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  end
end
