# frozen_string_literal: true

class UserRepository
  class << self
    def create(email, password)
      User.create!(email:, password:)
    end

    def find_by_id(id)
      User.find_by(id:)
    end

    def find_by_email(email)
      User.find_by(email:)
    end

    def find_by_activated(email, password)
      user = User.find_by(email:, activated: true)
      return user if user&.authenticate(password)
    end

    def activate(user)
      user.update!(activated: true)
    end
  end
end
