require 'json'

rails_versions = JSON.parse(Net::HTTP.get(URI('https://rubygems.org/api/v1/versions/rails.json')))
  .group_by { |version| version['number'] }.keys.select { |key| key !~ /rc|racecar|beta|pre/ }

%w(3.0 3.1 3.2 4.0 4.1 4.2 5.0).each do |version|
  appraise "rails_#{version}" do
    current_version = rails_versions.select { |key| key.match %r{\A#{version}} }.max

    gem 'activesupport', "~> #{current_version}"
    gem 'activerecord',  "~> #{current_version}"
  end
end
