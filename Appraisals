require 'json'

rubygems_api_url = URI('https://rubygems.org/api/v1/versions/rails.json')
versions = JSON.parse(Net::HTTP.get(rubygems_api_url)).group_by { |version| version['number'] }
keys = versions.keys.select { |key| key !~ /rc|racecar|beta|pre/ }

%w(3_0 3_1 3_2 4_0 4_1 4_2 5_0).each do |version|
  appraise "rails_#{version}" do
    version.gsub!(/_/, '.')

    version_regex = %r{\A#{version.sub('.', '\.')}\.(\d+)\Z}
    minor_version = keys.map { |key| key.scan(version_regex).flatten.first }.compact.map(&:to_i).max

    gem 'activesupport', "~> #{version}.#{minor_version}"
    gem 'activerecord',  "~> #{version}.#{minor_version}"
  end
end
