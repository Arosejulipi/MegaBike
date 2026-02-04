source "https://rubygems.org"

gem "rails", "~> 7.1.0"

gem "sqlite3", "~> 1.4"

group :production do
  gem "pg", "~> 1.5"
end


gem "puma", "~> 6.0"

gem "bcrypt", "~> 3.1"

# Asset pipeline for Rails 7
gem "sprockets-rails"

# Use Postmark for transactional emails in production (HTTP API, reliable deliverability)
gem "postmark-rails"

gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development do
  gem "letter_opener_web", "~> 2.0"
end
