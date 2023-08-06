# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
require_relative 'log_formatter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.default_locale = :ja

    config.enable_dependency_loading = true
    config.active_record.schema_format = :sql

    formatter = Logger::CustomFormatter.new
    config.logger = Logger.new("log/common-#{Time.current.strftime('%Y%m%d')}.log", 'daily')
    config.logger.formatter = formatter

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: true,
                       request_specs: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:3000'  # 本番環境の場合は適切なオリジンを設定
        resource '*', headers: :any, methods: %i[get post put delete options]
      end
    end
  end
end
