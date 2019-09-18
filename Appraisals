require 'net/http'
require 'json'

rails_versions = JSON.parse(Net::HTTP.get(URI('https://rubygems.org/api/v1/versions/rails.json')))
  .group_by { |version| version['number'] }.keys.reject { |key| key =~ /rc|racecar|beta|pre/ }

%w[4.2 5.0 5.1 5.2 6.0].each do |version|
  appraise "rails_#{version}" do
    current_version = rails_versions
      .select { |key| key.match(/\A#{version}/) }
      .max { |a, b| Gem::Version.new(a) <=> Gem::Version.new(b) }

    gem 'activesupport', "~> #{current_version}"
    gem 'activerecord',  "~> #{current_version}"

    gem 'sqlite3', Gem::Version.new(version) > Gem::Version.new(5.0) ? '~> 1.4.1' : '< 1.4'
  end
end
