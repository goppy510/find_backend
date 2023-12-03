# frozen_string_literal: true

module Contracts
  module ContractsError
    class DuplicateEntry < StandardError; end
    class EmailFormatError < StandardError; end
    class PasswordFormatError < StandardError; end
    class Forbidden < StandardError; end
    class RecordLimitExceeded < StandardError; end
  end
end
