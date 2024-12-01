require 'net/http'
require 'json'

rails_versions = JSON.parse(Net::HTTP.get(URI('https://rubygems.org/api/v1/versions/rails.json')))
  .group_by { |version| version['number'] }.keys.grep_v(/rc|racecar|beta|pre/)

%w[6.0 6.1 7.0 7.1 7.2 8.0].each do |rails_version|
  appraise "rails_#{rails_version}" do
    current_version = rails_versions
      .select { |key| key.match(/\A#{rails_version}/) }
      .max { |a, b| Gem::Version.new(a) <=> Gem::Version.new(b) }

    gem 'activesupport', "~> #{current_version}"
    gem 'activerecord',  "~> #{current_version}"

    if Gem::Version.new(rails_version) > Gem::Version.new(7.0)
      gem 'sqlite3'
    else
      gem 'sqlite3', '< 2' # Rails 6.x and 7.0 require sqlite3 v1.x
    end
  end
end
