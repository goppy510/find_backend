class Api::UserController < ApplicationController
  
  # 仮登録用
  def signup
    if params[:email].blank? || params[:password].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = SignupService.new(params[:email], params[:password])
    response = service.signup

    render json: response
  end

  # 新規登録時の確認メール送信用
  def submit_verify_email
    if params[:email].blank? or params[:token].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = VerifyEmailService.new(params[:email], params[:token])
    response = service.verify_email

    render json: response
  end

  # 確認メールクリック後
  def activate_account
    if params[:email].blank? or params[:token].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = VerifyEmailService.new(params[:email], params[:token])
    response = service.activate_account

    render json: response
  end

  # ログイン
  def login
    if params[:login_id].blank? || params[:password].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = LoginService.new(params[:login_id], params[:password])
    response = service.login

    render json: response
  end

  # ログアウト
  def logout
    if params[:token].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = LogoutService.new(params[:token])
    response = service.logout

    render json: response
  end

  # ユーザー情報閲覧用
  def show
    if params[:token].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = AccountService.new(params[:token])
    service.show
  end

  # パスワード更新用
  def update_password
    if params[:token].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = AccountService.new(params[:token])
    service.update_password
  end

  # プロフィール更新用
  def update_profile
    if params[:token].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    user_service = AccountService.new(params[:token])
    user_service.update_profile
  end
end
