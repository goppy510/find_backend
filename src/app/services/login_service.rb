# frozen_string_literal: true

class LoginService
  class << self
    def create(logins)
      Login::LoginDomain.create(logins)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end
  end
end
