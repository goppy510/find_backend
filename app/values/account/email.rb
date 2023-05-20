#frozen_string_literal: true

class Email
  attr_reader :value

  def initialize(value)
    unless value
      raise ArgumentError, 'emailがありません'
    end

    unless email_valid?(value)
      raise EmailFormatError, 'emailの形式が正しくありません'
    end

    @value = value

    self.freeze
  end

  private

  def email_valid?(value)
    email_format = /\A[a-zA-Z0-9_\#!$%&`'*+\-{|}~^\/=?\.]+@[a-zA-Z0-9][a-zA-Z0-9\.-]+\z/
    value =~ email_format
  end

  class << self
    def from_string(value)
      self.new(value)
    end
  end
  
end

class EmailFormatError < StandardError; end
