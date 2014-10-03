source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'

if RUBY_PLATFORM == 'java'
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
else
  gem 'pg'
  gem 'sqlite3'
end

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'spring'
end
# Use debugger
# gem 'debugger', group: [:development, :test]


group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'guard-rspec', require: false
  # gem 'better_errors'
  # gem 'binding_of_caller'
  gem 'letter_opener'
end

group :test do
  gem 'shoulda'
  gem 'database_cleaner'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'webmock'
  gem 'vcr'
  gem 'capybara'
  gem 'mock_redis'
  gem 'simplecov', '~> 0.7.1', require: false
end

gem 'couchsurfing_client', git: 'https://github.com/unmanbearpig/couchsurfing_client'

gem 'dalli' # memcached

gem 'devise'
gem 'haml'
gem 'foundation-rails'
gem 'pg_search'
gem 'sidekiq'
gem 'redis-namespace'
gem 'knockoutjs-rails'
gem 'gon'
gem 'jquery-turbolinks'

gem 'puma'



# for sidekiq ui
gem 'sinatra', '>= 1.3.0', :require => nil

gem 'whenever', require: nil

gem 'rack-mini-profiler', require: false
gem 'flamegraph' unless RUBY_PLATFORM == 'java'

# gem 'git_store', git: 'https://github.com/unmanbearpig/git_store.git'

# neo4j
# gem "neo4j-community", '~> 2.1.1' # neo4j-core bug? - it fails to require this gem for some reason
# gem 'neo4j-core', git: 'https://github.com/neo4jrb/neo4j-core.git'
# gem 'neo4j', git: 'https://github.com/neo4jrb/neo4j.git'

# gem 'neography'
