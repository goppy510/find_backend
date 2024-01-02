# frozen_string_literal: true

module Login
  module LoginError
    class EmailFormatError < StandardError; end
    class PasswordFormatError < StandardError; end
  end
end
