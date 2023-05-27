#frozen_string_literal: true

class UserRepository
  class << self

    def create(email, passsword)
      User.create!(email: email, password: password)
    end

    def find_by_id(id)
      User.find(id)
    end

    def find_by_email(email)
      User.find_by(email: email)
    end

    def find_by_activated(email, password)
      user = User.find_by(email: email, activated: true)
      return user if user&.authenticate(password)
    end
  end
end
