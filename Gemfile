source 'https://rubygems.org'

# Specify your Ruby version
ruby '2.7.3'

# Rails gem
gem 'rails', '~> 6.1.4'

# Database gems
gem 'sqlite3', '~> 1.4' # Use sqlite3 as the database for Active Record
# Uncomment the following line if you're using PostgreSQL
# gem 'pg', '>= 0.18', '< 2.0'

# Web server gem
gem 'puma', '~> 5.0'

# Gems used by ActiveRecord
gem 'activerecord', '~> 6.1.4'
gem 'activemodel', '~> 6.1.4'
gem 'activesupport', '~> 6.1.4'
gem 'activerecord-import', '~> 1.0'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Authentication gems
gem 'devise'
gem 'omniauth'

# Authorization gem
gem 'cancancan'

# Pagination gem
gem 'kaminari'

# API documentation gem
gem 'rswag'

# Testing gems
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Use Capistrano for deployment
  gem 'capistrano', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-passenger', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

group :production do
  gem 'pg'
  gem 'puma'
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
