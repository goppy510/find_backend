class ActivationMailer < ApplicationMailer
  default :from => Settings[:mail][:from]

  def send_activation_email(email, token, expires_at)
    @email = email
    @url = "#{Settings[:app][:host]}/activation?token=#{token}"
    @expires_at = expires_at.strftime('%Y-%m-%d %H:%M:%S')

    subject_content = '【find-market】本登録のお願い'

    mail to: @email, subject: subject_content
  end
end
