# frozen_string_literal: true

class ContractMembership < ApplicationRecord
  belongs_to :user
  belongs_to :contract

  before_destroy :destroy_user

  private

  def destroy_user
    user.destroy
  end
end
