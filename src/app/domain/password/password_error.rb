# frozen_string_literal: true

module Password
  module PasswordError
    class Unauthorized < StandardError; end
    class PasswordFormatError < StandardError; end
  end
end
