# frozen_string_literal: true

class Account
  class PhoneNumber
    attr_reader :value

    def initialize(value)
      raise ArgumentError, 'phone_numberがありません' unless value
      raise FormatError, '形式が正しくありません' unless phone_number_valid?(value)

      @value = value

      freeze
    end

    private

    def phone_number_valid?(value)
      cell_phone_format = /\A0[5789]0\d{8}\z/
      office_phone_format = /\A0\d{1,4}\d{1,4}\d{4}\z/
      value =~ cell_phone_format || value =~ office_phone_format
    end

    class << self
      def from_string(value)
        new(value).value.to_s
      end
    end
  end
end

class FormatError < StandardError; end
