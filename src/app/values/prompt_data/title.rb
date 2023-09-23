# frozen_string_literal: true

module PromptData
  class Title
    attr_reader :value

    LENGTH = 255

    def initialize(value)
      raise ArgumentError, 'titleがありません' unless value
      raise FormatError, '形式が正しくありません' unless valid?(value)

      @value = value

      freeze
    end

    private

    def valid?(value)
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
