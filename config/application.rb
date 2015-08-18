require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
require "./lib/extensions/string.rb"
require "./lib/extensions/scraper.rb"
# require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module IntralistApp
  class Application < Rails::Application
    config.generators do |g|
      g.view_specs false
      g.helper_specs false
    end
    config.encoding = "utf-8"
    config.filter_parameters += [:password, :password_confirmation]
    config.active_support.escape_html_entities_in_json = true
    config.assets.enabled = true
    config.assets.version = '2.0'
    # NOTE: not sure how necesary this is, but commenting this out allowed Intralist to work on Heroku
    # config.assets.initialize_on_precompile = false
    # added below to support HAML templates for Angular
    config.assets.paths << Rails.root.join('app', 'assets', 'templates')


    config.to_prepare do
      Devise::SessionsController.layout "application"
      Devise::RegistrationsController.layout proc{ |controller| user_signed_in? ? "application"   : "application" }
      Devise::PasswordsController.layout "application"
    end
    
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
         :authentication => :plain,
         :address => "smtp.mailgun.org",
         :port => 587,
         :domain => "intralist.com",
         :user_name => "rubyspider@intralist.com",
         :password => "1111111111"
    }
  end
end
