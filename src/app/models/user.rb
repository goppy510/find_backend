# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_one :profile

  has_many :likes, dependent: :destroy
  has_many :liked_prompts, through: :likes, source: :prompt

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_prompts, through: :bookmarks, source: :prompt
  
  has_many :prompts, dependent: :nullify

  has_many :permissions
  has_many :resources, through: :permissions

  # 中間テーブルとのアソシエーション
  has_many :contract_memberships, dependent: :destroy
  has_many :contracts, through: :contract_memberships

  # UserがContractの管理者として関連付けられている場合のアソシエーション
  has_one :contract, class_name: 'Contract', foreign_key: 'user_id', dependent: :destroy
end
