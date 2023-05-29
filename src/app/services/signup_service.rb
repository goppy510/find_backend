#frozen_string_literal: true

class SignupService
  include SessionModule

  attr_reader :email, :password, :token, :expires_at

  def initialize(email, password)
    raise ArgumentError, 'emailまたはpasswordがありません' if email.blank? or password.blank?
    @email = Account::Email.from_string(email)
    @password = Account::Password.from_string(password)

    self.freeze
  end

  # ユーザー情報をDBに登録する
  def signup
    UserRepository.create(@email, @password)
  rescue ActiveRecord::RecordInvalid => e
    raise SignupError, e.message
  end

  # 本登録用のメールを送信する
  def activation_email

    user = UserRepository.find_by_email_not_activated(@email)
    raise UserNotFound, '指定のユーザーが見つかりませんでした' unless user

    # アクティベーションメールのリンクのクエリパラメータに入れるJWTを生成する
    payload = signup_payload(user)
    auth = generate_token(payload) #SessionModuleのメソッド
    token = auth.token
    expires_at = toTime(auth) #SessionModuleのメソッド

    # メールの作成と送信
    ActivationMailer.send_activation_email(email, token, expires_at).deliver
  end

  private

  # アクティベーション用のトークン生成のためのペイロード
  def signup_payload(user)
    {
      sub: user.id,
      type: 'activation'
    }
  end
end

class SignupError < StandardError; end
class UserNotFound < StandardError; end
class SubmitVerifyEmailError < StandardError; end
