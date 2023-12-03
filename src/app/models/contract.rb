# frozen_string_literal: true

class Contract < ApplicationRecord
  # 管理者としてのUserへの関連
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  
  # メンバーとしてのUserへの関連
  has_many :contract_memberships, dependent: :destroy
  has_many :users, through: :contract_memberships
end
