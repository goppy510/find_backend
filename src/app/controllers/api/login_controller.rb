#frozen_string_literal: true

class Api::LoginController < ApplicationController
  before_action :delete_cookie
  before_action :authenticate, only: [:login]

  # ログイン
  def create
    service = LoginService.new(params[:email], params[:password])
    res = service.login
    render_error(:unauthorized, :user, :unauthorized) unless res

    cookies[token_access_key] = res[:auth]
    render json: { res[:user] }
  end

  # ログアウト
  def destroy
    head(:ok)
  end
end
