# frozen_string_literal: true

module PromptData
  class About
    attr_reader :value

    LENGTH = 4096

    def initialize(value)
      raise ArgumentError, 'aboutがありません' unless value
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
