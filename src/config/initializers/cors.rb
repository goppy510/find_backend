# frozen_string_literal: true

unless Rails.env.test?
  App::Application.config.middleware.insert_before 0, Rack::Cors do
    if Rails.env.development?
      allow do
        origins '*'
        resource '*', headers: :any, methods: :any
      end
    end
  end
end
