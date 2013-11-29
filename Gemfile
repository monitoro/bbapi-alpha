source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

gem 'acts-as-taggable-on'
gem 'paperclip'
gem 'aws-sdk', '~> 1.5.7'

gem 'rails-api'
gem 'rack-cors', :require => 'rack/cors'
gem 'coderay', '=1.0.9'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'coveralls', require: false
  gem 'factory_girl', :require => false
  gem 'factory_girl_rails', :require => false
  gem 'faker'
  gem 'database_cleaner', '=1.0.1' # Clean database between tests
  gem 'rspec-rails'       # Test framework
  gem 'shoulda'               # nice rspec matchers
end

group :development, :test do
  gem 'fabrication'           # Test object generation
  gem 'spring'
  gem 'guard', '~> 2'
  gem 'guard-rspec',require: false
end

gem 'devise'                   # server-side authentication
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-github'

gem 'mini_fb'

gem 'dotenv-rails', groups: [:development, :test]

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby'              # password encryption

# for easy RESTful API controller scaffolding
# gem 'inherited_resources'      

# works out of the box with ember-data
gem 'active_model_serializers' 


gem 'coveralls', require: false


# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'kaminari'

# gem 'debugger'