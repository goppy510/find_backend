class User < ApplicationRecord
  has_secure_password
  has_one :registration_token
  has_one :profile

  # to_token等を使えるようにするためのもの
  include Auth::TokenizableService
end
