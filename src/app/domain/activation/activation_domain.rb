# frozen_string_literal: true

# ユーザーがアクティベーションメールのリンクをクリックしたらアカウントを有効化するためのもの
module Activation
  class ActivationDomain
    include SessionModule
    include Activation::ActivationError

    def initialize(token)
      @token = token
    end

    # アクティベート
    def activate
      authenticate_user_not_activate(@token) # SessionModuleのメソッド
      raise  Activation::ActivationError::Unauthorized unless @auth

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
end
