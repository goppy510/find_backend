# frozen_string_literal: true

class SignupService
  include SessionModule

  attr_reader :email, :password, :token, :expires_at

  def initialize(email, password)
    raise ArgumentError, 'emailまたはpasswordがありません' if email.blank? || password.blank?

    @email = Account::Email.from_string(email)
    @password = Account::Password.from_string(password)

    freeze
  end

  # ユーザー情報をDBに登録する
  def add
    UserRepository.create(@email, @password)
  rescue ActiveRecord::RecordInvalid => e
    raise SignupError, e.message
  end

  # 本登録用のメールを送信する
  def activation_email
    user = UserRepository.find_by_email(@email)
    raise Unauthorized, '指定のユーザーが見つかりませんでした' if user.blank? || user&.activated

    # アクティベーションメールのリンクのクエリパラメータに入れるJWTを生成する
    payload = signup_payload(user)
    auth = generate_token(lifetime: Auth.token_signup_lifetime, payload:) # SessionModuleのメソッド
    token = auth.token
    expires_at = Time.zone.at(auth.payload[:exp]) # SessionModuleのメソッド

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

  class << self
    def signup(email, password)
      service = SignupService.new(email, password)
      service&.add
      service&.activation_email
    end
  end
end

class SignupError < StandardError; end
class Unauthorized < StandardError; end
class SubmitVerifyEmailError < StandardError; end
