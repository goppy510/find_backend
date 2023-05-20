#frozen_string_literal: true

class Password
  attr_reader :value

  def initialize(value)
    unless value
      raise ArgumentError, 'passwordがありません'
    end

    unless password_valid?(value)
      raise PasswordFormatError, 'passwordの形式が正しくありません'
    end

    @value = value

    self.freeze
  end

  private

  def password_valid?(input_value)
    value = input_value.to_s
  
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
      self.new(value)
    end
  end
  
end

class PasswordFormatError < StandardError; end
