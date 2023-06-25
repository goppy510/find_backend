# frozen_string_literal: true

module Account
  class Name
    attr_reader :value

    LENGTH = 50

    def initialize(value)
      raise ArgumentError, 'nameがありません' unless value
      raise FormatError, '形式が正しくありません' unless name_valid?(value)

      @value = value

      freeze
    end

    private

    def name_valid?(value)
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
