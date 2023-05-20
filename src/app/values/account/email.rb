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
    email_format = /\A[\w+\-]+(?:\.[\w+\-]+)*@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]{2,}\z/i
    value =~ email_format
  end

  class << self
    def from_string(value)
      self.new(value)
    end
  end
  
end

class EmailFormatError < StandardError; end
