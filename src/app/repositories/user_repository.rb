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

    def update_password(user_id, current_password, new_password)
      user = User.find_by(id: user_id)
      raise IncorrectPasswordError unless user.authenticate(current_password)

      user.update(password: new_password, password_confirmation: new_password)
    end
  end
end

class IncorrectPasswordError < StandardError; end
