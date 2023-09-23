# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :prompt

  # 同じユーザーが同じプロンプトを複数回「いいね」できないようにする
  validates :user_id, uniqueness: { scope: :prompt_id }
end
