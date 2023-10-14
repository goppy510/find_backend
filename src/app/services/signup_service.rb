# frozen_string_literal: true

class SignupService
  include SessionModule

  class DuplicateEntry < StandardError; end
  class Unauthorized < StandardError; end
  class EmailFormatError < StandardError; end
  class PasswordFormatError < StandardError; end

  attr_reader :email,
              :password,
              :user_id,
              :expires_at

  def initialize(signups: nil, token: nil)
    hash_signups = signups[:signups] if signups.present?
    hash_token = token[:token] if token.present?
    @user_id = authenticate_user(hash_token)[:user_id] if hash_token.present?

    @email = Account::Email.from_string(hash_signups[:email]) if hash_signups&.key?(:email)
    @password = Account::Password.from_string(hash_signups[:password]) if hash_signups&.key?(:password)

    freeze
  end

  # ユーザー情報をDBに登録する
  def add
    UserRepository.create(@email, @password)
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error(e)
    raise DuplicateEntry
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e)
    raise e
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
    def signup(signups, token)
      raise ArgumentError, 'emailがありません' if signups[:signups][:email].blank?
      raise ArgumentError, 'passwordがありません' if signups[:signups][:password].blank?

      service = SignupService.new(signups:, token:)
      service&.add

      # contract権限がなければメールアドレス登録直後にメールを送る
      return if token and token[:token] and PermissionService.has_contract?(token[:token])

      service&.activation_email 
    rescue Account::Email::EmailFormatError => e
      Rails.logger.error(e)
      raise EmailFormatError
    rescue Account::Password::PasswordFormatError => e
      Rails.logger.error(e)
      raise PasswordFormatError
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end
  end
end
