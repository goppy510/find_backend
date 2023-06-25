# frozen_string_literal: true

module Account
  class CompanyName
    attr_reader :value

    LENGTH = 100

    def initialize(value)
      raise ArgumentError, 'compnay_nameがありません' unless value
      raise FormatError, '形式が正しくありません' unless company_name_valid?(value)

      @value = value

      freeze
    end

    private

    def company_name_valid?(value)
      value.length <= LENGTH
    end

    class << self
      def from_string(value)
        new(value).value.to_s
      end
    end
  end
end

class FormatError < StandardError; end
