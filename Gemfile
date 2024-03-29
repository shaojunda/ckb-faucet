# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.3", ">= 6.0.3.1"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 4.3.9"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# CKB SDK
gem "ckb-sdk-ruby", git: "https://github.com/nervosnetwork/ckb-sdk-ruby.git", require: "ckb", branch: "develop"

# Serializer
gem "fast_jsonapi"

# Deployment
gem "mina", require: false
gem "mina-multistage", require: false

# Pagination
gem "kaminari", ">= 1.2.1"

# Cron Job
gem "whenever", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

# Throttling
gem "rack-attack"

group :development, :test do
  gem "pry"
  gem "pry-nav"
  gem "factory_bot_rails"
end

group :development do
  gem "listen", "~> 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "annotate"
  gem "awesome_print"
  gem "rubocop", require: false
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "simplecov", require: false
  gem "minitest-reporters"
  gem "shoulda-context"
  gem "shoulda-matchers"
  gem "database_cleaner"
  gem "mocha"
  gem "faker", git: "https://github.com/stympy/faker.git", branch: "master"
  gem "codecov", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
