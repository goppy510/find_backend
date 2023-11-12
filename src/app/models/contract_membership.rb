# frozen_string_literal: true

class ContractMembership < ApplicationRecord
  belongs_to :user
  belongs_to :contract
end

