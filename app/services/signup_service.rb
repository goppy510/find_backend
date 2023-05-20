#frozen_string_literal: true

class SignupService
  attr_reader :email, :password

  def initialize(email, password)
    unless
      raise ArgumentError, 'emailがありません'
    end

    unless email_valid?(email)
      raise EmailFormatError, 'emailの形式が正しくありません'

    if password
      raise InvalidPasswordParameterError, 'passwordがありません'
    end

    @email = email
    @password = password

    self.freeze
  end


  def signup
    User.create(email: @email, password_digest: @password)
  rescue ActiveRecord::RecordInvalid => e
    raise InvalidUserError, e.message
  end





  def password_valid?(password)
    MIN_LEN = 8
    MAX_LEN = 50
    return false unless (MIN_LEN..MAX_LEN).include?(password.length)

    # 大文字、小文字、数字、記号の存在を確認
    has_lowercase = password =~ /[a-z]/
    has_uppercase = password =~ /[A-Z]/
    has_digit = password =~ /\d/
    has_symbol = password =~ /[\W_]/

    # すべての条件を満たしている場合にのみtrueを返す
    has_lowercase && has_uppercase && has_digit && has_symbol
  end
end


class InvalidPasswordParameterError < StandardError;
class InvalidUserError < StandardError; end
