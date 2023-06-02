#frozen_string_literal: true

require 'securerandom'

class Account::Registration

  class << self
    def token
      SecureRandom.uuid
    end

    def expires_at
      Time.current.in_time_zone + 1.hour
    end
  end
end
