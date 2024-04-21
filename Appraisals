require 'net/http'
require 'json'

rails_versions = JSON.parse(Net::HTTP.get(URI('https://rubygems.org/api/v1/versions/rails.json')))
  .group_by { |version| version['number'] }.keys.grep_v(/rc|racecar|beta|pre/)

%w[5.0 5.1 5.2 6.0 6.1 7.0 7.1].each do |rails_version|
  appraise "rails_#{rails_version}" do
    current_version = rails_versions
      .select { |key| key.match(/\A#{rails_version}/) }
      .max { |a, b| Gem::Version.new(a) <=> Gem::Version.new(b) }

    gem 'activesupport', "~> #{current_version}"
    gem 'activerecord',  "~> #{current_version}"

    if Gem::Version.new(rails_version) <= Gem::Version.new(5.0)
      gem 'sqlite3', '< 1.4'
    else
      # v2.x isn't yet working. See: https://github.com/sparklemotion/sqlite3-ruby/issues/529
      gem 'sqlite3', '< 2'
    end

    # elsif Gem::Version.new(RUBY_VERSION) < '3'
    #   gem 'sqlite3', '< 2'
    # else
    #   gem 'sqlite3'
    # end
  end
end
