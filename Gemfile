source 'https://rubygems.org'
ruby "2.1.2"

ruby '2.1.2'

gem 'rails', '~> 3.2.18'

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', "2.1.3"
gem "mongoid", ">= 3.1.1"

# Authentication

gem "devise", "~> 2.1.2"
gem "omniauth", ">= 1.1.0"
gem "omniauth-facebook"
gem "omniauth-twitter"

# Styling / Templating

gem 'haml-rails', '>= 0.3.4'
gem 'therubyracer', '0.12.1'
gem 'less-rails-bootstrap'
gem 'angular-rails-templates'

# Pagination

gem 'kaminari'
gem 'resque', '~> 1.25.2'
gem 'resque-web', require: 'resque_web'

# Other fun things
gem 'mongoid_vote'

# Utilities
gem "active_model_serializers", "0.9.0.alpha1"

# Uploads and Images

gem 'remotipart'
gem "fog"
gem 'rmagick'
gem 'carrierwave',  :github => "carrierwaveuploader/carrierwave"
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem "jquery-fileupload-rails"

# 3rd party interaction

gem 'koala'
gem 'twitter', '~> 4.6.2'
gem 'httparty'

# Search
gem 'elasticsearch-rails'
gem 'elasticsearch-model'

# Web

gem 'unicorn'

# Testing

gem "rspec-rails", ">= 2.11.0", :group => [:development, :test]
gem "factory_girl_rails", ">= 4.0.0", :group => [:development, :test]

group :test do
  gem "database_cleaner", ">= 0.8.0"
  gem "mongoid-rspec", ">= 1.4.6"
  gem "launchy", ">= 2.1.2"
end

group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'pry-nav'
  gem 'awesome_print'
  gem 'mongoid-colors'
  gem 'spring'
  gem "spring-commands-rspec"
  gem 'byebug'
end

#Web Server Utils

gem 'powder'
gem 'newrelic_rpm'
