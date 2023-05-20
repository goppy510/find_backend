#frozen_string_literal: true

require 'securerandom'

class RegistrationToken

  class << self
    def generate
      SecureRandom.uuid
    end
  end
  
end
