require 'net/http'
require 'json'

rails_versions = JSON.parse(Net::HTTP.get(URI('https://rubygems.org/api/v1/versions/rails.json')))
  .group_by { |version| version['number'] }.keys.reject { |key| key =~ /rc|racecar|beta|pre/ }

%w[3.0 3.1 3.2 4.0 4.1 4.2 5.0 5.1].each do |version|
  appraise "rails_#{version}" do
    current_version = rails_versions
      .select { |key| key.match(/\A#{version}/) }
      .sort { |a, b| Gem::Version.new(a) <=> Gem::Version.new(b) }
      .last

    gem 'activesupport', "~> #{current_version}"
    gem 'activerecord',  "~> #{current_version}"
  end
end
