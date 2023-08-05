# frozen_string_literal: true

# ユーザーがアクティベーションメールのリンクをクリックしたらアカウントを有効化するためのもの
class ActivationService
  include SessionModule

  def initialize(token)
    @token = token
  end

  # アクティベート
  def activate
    authenticate_user_not_activate(@token) # SessionModuleのメソッド
    raise Unauthorized unless @auth

    # アクティベートする
    user = UserRepository.find_by_id(@auth[:user_id])

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

class Unauthorized < StandardError; end
