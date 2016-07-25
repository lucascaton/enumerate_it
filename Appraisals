%w(3_0 3_1 3_2 4_0 4_1 4_2 5_0).each do |version|
  appraise "activesupport_#{version}" do
    gem 'activesupport', "~> #{version.gsub(/_/, '.')}.0"
    gem 'activerecord',  "~> #{version.gsub(/_/, '.')}.0"
  end
end
