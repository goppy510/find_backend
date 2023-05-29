#frozen_string_literal: true

class UserRepository
  class << self

    def create(email, password)
      User.create!(email: email, password: password)
    end

    def find_by_id(id)
      User.find_by(id: id, activated: true)
    end

    def find_by_email_not_activated(email)
      User.find_by(email: email, activated: false)
    end

    def find_by_id_not_activated(id)
      User.find_by(id: id, activated: false)
    end

    def find_by_email(email)
      User.find_by(email: email, activated: true)
    end

    def find_by_activated(email, password)
      user = User.find_by(email: email, activated: true)
      return user if user&.authenticate(password)
    end

    def activate(user)
      user.update!(activated: true)
    end
  end
end
