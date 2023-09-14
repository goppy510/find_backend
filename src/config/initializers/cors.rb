# frozen_string_literal: true

unless Rails.env.test?
  App::Application.config.middleware.insert_before 0, Rack::Cors do
    if Rails.env.development?
      allow do
        origins 'http://localhost:8080'
        resource '*',
                  headers: :any,
                  methods: %i[get post put patch delete options head]
      end
    end
  end
end
