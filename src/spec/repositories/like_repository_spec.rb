# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe LikeRepository do
  describe '#create' do
    context '正常系' do
      context 'user_idとprompt_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user_creator) { create(:user, activated: true) }
        let!(:user_1) { create(:user, activated: true) }
        let!(:user_2) { create(:user, activated: true) }
        let!(:prompt) { create(:prompt, user_id: user_creator.id) }

        it 'promptに対するlikesの個数が2であること' do
          LikeRepository.create(user_1.id, prompt.id)
          LikeRepository.create(user_2.id, prompt.id)
          likes = Like.where(prompt_id: prompt.id)
          expect(likes.length).to eq(2)
        end
      end
    end
  end

  describe '#delete' do
    context '正常系' do
      context 'user_idとprompt_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user_creator) { create(:user, activated: true) }
        let!(:user_1) { create(:user, activated: true) }
        let!(:user_2) { create(:user, activated: true) }
        let!(:prompt) { create(:prompt, user_id: user_creator.id) }
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompt.id) }

        it 'promptに対するlikesの個数が1であること' do
          LikeRepository.delete(user_1.id, prompt.id)
          likes = Like.where(prompt_id: prompt.id)
          expect(likes.length).to eq(1)
        end
      end
    end
  end

  describe '#count' do
    context '正常系' do
      context 'prompt_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user_creator) { create(:user, activated: true) }
        let!(:user_1) { create(:user, activated: true) }
        let!(:user_2) { create(:user, activated: true) }
        let!(:prompt) { create(:prompt, user_id: user_creator.id) }
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompt.id) }

        it 'promptに対するlikesの個数が2であること' do
          cnt = LikeRepository.count(user_1.id, prompt.id)
          expect(cnt[:count]).to eq(2)
        end

        it 'trueを返すこと' do
          cnt = LikeRepository.count(user_1.id, prompt.id)
          expect(cnt[:is_liked]).to eq(true)
        end
      end
    end
  end
end
