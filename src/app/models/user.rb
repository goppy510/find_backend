class User < ApplicationRecord
  has_secure_password
  has_one :registration_token
  has_one :profile

  include Auth::TokenizableService
end
