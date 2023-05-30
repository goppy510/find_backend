#frozen_string_literal: true

class Api::LoginController < ApplicationController
  include Session

  # ログイン
  def create
    login
  end

  # ログアウト
  def destroy
    logout
  end
end
