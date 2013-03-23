require 'matchers/has_enumerate_it'

RSpec::configure do |config|
  config.include(EnumerateIt::Matchers)
end
