#frozen_string_literal: true

class Account::Password
  attr_reader :value

  def initialize(value)
    raise ArgumentError, 'passwordがありません' unless value
    raise PasswordFormatError, 'passwordの形式が正しくありません' unless password_valid?(value)

    @value = value
  end

  private

  def password_valid?(value)
    min_len = 8
    max_len = 50
    return false unless (min_len..max_len).include?(value.length)

    # 大文字、小文字、数字、記号の存在を確認
    has_lowercase = value =~ /[a-z]/
    has_uppercase = value =~ /[A-Z]/
    has_digit = value =~ /\d/
    has_symbol = value =~ /[\W_]/

    # すべての条件を満たしている場合にのみtrueを返す
    has_lowercase && has_uppercase && has_digit && has_symbol
  end

  class << self
    def from_string(value)
      new(value).value.to_s
    end
  end
  
end

class PasswordFormatError < StandardError; end
