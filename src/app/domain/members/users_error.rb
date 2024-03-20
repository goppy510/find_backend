# frozen_string_literal: true

module Members
  module UsersError
    class DuplicateEntry < StandardError; end
    class EmailFormatError < StandardError; end
    class PasswordFormatError < StandardError; end
    class Forbidden < StandardError; end
    class RecordLimitExceeded < StandardError; end
  end
end
