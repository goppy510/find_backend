# frozen_string_literal: true

module Signup
  module SignupError
    class DuplicateEntry < StandardError; end
    class EmailFormatError < StandardError; end
    class PasswordFormatError < StandardError; end
    class RecordLimitExceeded < StandardError; end
    class Forbidden < StandardError; end
  end
end
