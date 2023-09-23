# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe BookmarkRepository do
  describe '#create' do
    context '正常系' do
      context 'user_idとprompt_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email_creator) { Faker::Internet.email }
        let!(:email_1) { Faker::Internet.email }
        let!(:email_2) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user_creator) { create(:user, email: email_creator, password:, activated: true) }
        let!(:user_1) { create(:user, email: email_1, password:, activated: true) }
        let!(:user_2) { create(:user, email: email_2, password:, activated: true) }
        let!(:prompt) { create(:prompt, user_id: user_creator.id) }

        it 'promptに対するbookmarksの個数が2であること' do
          BookmarkRepository.create(user_1.id, prompt.id)
          BookmarkRepository.create(user_2.id, prompt.id)
          bookmarks = Bookmark.where(prompt_id: prompt.id)
          expect(bookmarks.length).to eq(2)
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
        let!(:email_creator) { Faker::Internet.email }
        let!(:email_1) { Faker::Internet.email }
        let!(:email_2) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user_creator) { create(:user, email: email_creator, password:, activated: true) }
        let!(:user_1) { create(:user, email: email_1, password:, activated: true) }
        let!(:user_2) { create(:user, email: email_2, password:, activated: true) }
        let!(:prompt) { create(:prompt, user_id: user_creator.id) }
        let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompt.id) }

        it 'promptに対するbookmarksの個数が1であること' do
          BookmarkRepository.delete(user_1.id, prompt.id)
          bookmarks = Bookmark.where(prompt_id: prompt.id)
          expect(bookmarks.length).to eq(1)
        end
      end
    end
  end

  describe '#show_by_prompt_id' do
    context '正常系' do
      context 'prompt_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email_creator) { Faker::Internet.email }
        let!(:email_1) { Faker::Internet.email }
        let!(:email_2) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user_creator) { create(:user, email: email_creator, password:, activated: true) }
        let!(:user_1) { create(:user, email: email_1, password:, activated: true) }
        let!(:user_2) { create(:user, email: email_2, password:, activated: true) }
        let!(:prompt) { create(:prompt, user_id: user_creator.id) }
        let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompt.id) }

        it 'promptに対するbookmarksの個数が2であること' do
          BookmarkRepository.show_by_prompt_id(prompt.id)
          bookmarks = Bookmark.where(prompt_id: prompt.id)
          expect(bookmarks.length).to eq(2)
        end
      end
    end
  end
end
