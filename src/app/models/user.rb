class User < ApplicationRecord
  has_secure_password
  has_one :registration_token
end
