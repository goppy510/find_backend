# frozen_string_literal: true

# ユーザーがアクティベーションメールのリンクをクリックしたらアカウントを有効化するためのもの
class ActivationService
  include SessionModule

  def initialize(token)
    @token = token
  end

  # アクティベート
  def activate
    auth = authenticate_user_not_activate(@token) # SessionModuleのメソッド
    raise AuthenticationError unless auth

    # アクティベートする
    user = UserRepository.find_by_id(auth[:user_id])
    raise UserNotFound if user.blank? || user&.activated

    UserRepository.activate(user)
  end

  class << self
    def activate(token)
      raise ArgumentError, 'tokenがありません' unless token

      service = new(token)
      service&.activate
    end
  end
end

class AuthenticationError < StandardError; end
class UserNotFound < StandardError; end
