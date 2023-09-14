# frozen_string_literal: true

class ActivationMailer < ApplicationMailer
  default from: Settings[:mail][:from]

  def send_activation_email(email, token, expires_at)
    @email = email
    Rails.logger.debug Settings[:app][:domain]
    @url = "#{Settings[:app][:domain]}/activation?token=#{token}"
    @expires_at = expires_at.in_time_zone('Tokyo').strftime('%Y-%m-%d %H:%M:%S')

    subject_content = '【find-market】本登録のお願い'

    mail to: @email, subject: subject_content
  end
end
