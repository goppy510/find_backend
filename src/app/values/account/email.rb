# frozen_string_literal: true

module Account
  class Email
    class EmailFormatError < StandardError; end
    attr_reader :value

    def initialize(value)
      raise ArgumentError, 'emailがありません' unless value
      raise EmailFormatError, 'emailの形式が正しくありません' unless email_valid?(value)

      @value = value.downcase
    end

    private

    def email_valid?(value)
      email_format = /\A[\w+-]+(?:\.[\w+-]+)*@[a-z\d-]+(?:\.[a-z\d-]+)*\.[a-z]{2,}\z/i
      value =~ email_format
    end

    class << self
      def from_string(value)
        new(value).value.to_s
      end
    end
  end
end
