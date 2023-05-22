class RegsitrationMailer < ApplicationMailer
  default :from => Settings[:mail][:from]

  def send_registration_mail(email, token, expires_at)
    @email = email
    @url = "#{Settings[:app][:host]}/activation?token=#{token}"
    @expires_at = expires_at

    subject_content = '【find-market】本登録のお願い'

    mail to: @email, subject: subject_content
  end
end
