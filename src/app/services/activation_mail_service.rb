# frozen_string_literal: true

class ActivationMailService
  include SessionModule

  class Unauthorized < StandardError; end
  class EmailFormatError < StandardError; end

  attr_reader :email

  def initialize(email)
    @email = Account::Email.from_string(email) if email

    freeze
  end

  # 本登録用のメールを送信する
  def activation_email
    user = UserRepository.find_by_email(@email)
    raise Unauthorized if user.blank? || user&.activated

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
    def activation_email(email)
      raise ArgumentError, 'emailがありません' if email.blank?

      service = ActivationMailService.new(email)
      service&.activation_email
      Rails.logger.info("Activation Email sended to: #{email}")
    rescue Account::Email::EmailFormatError => e
      Rails.logger.error(e)
      raise EmailFormatError
    rescue Unauthorized => e
      Rails.logger.error(e)
      raise e
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end
  end
end
