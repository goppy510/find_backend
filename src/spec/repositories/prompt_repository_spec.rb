# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PromptRepository do
  describe '#create' do
    context '正常系' do
      context 'user_idとpromptsを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:prompts_for_create) do
          {
            about: 'about',
            title: 'title',
            input_example: 'input_example',
            output_example: 'output_example',
            prompt: 'prompt',
            generative_ai_model_id: 1,
            category_id: 2,
            uuid: 'uuid'
          }
        end

        it 'userのidでpromptsにインサートされること' do
          PromptRepository.create(user.id, prompts_for_create)
          prompts = Prompt.find_by(user_id: user.id)
          expect(prompts.user_id).to eq(user.id)
          expect(prompts.uuid).to eq(prompts_for_create[:uuid])
          expect(prompts.category_id).to eq(prompts_for_create[:category_id])
          expect(prompts.about).to eq(prompts_for_create[:about])
          expect(prompts.input_example).to eq(prompts_for_create[:input_example])
          expect(prompts.output_example).to eq(prompts_for_create[:output_example])
          expect(prompts.prompt).to eq(prompts_for_create[:prompt])
          expect(prompts.generative_ai_model_id).to eq(prompts_for_create[:generative_ai_model_id])
        end
      end
    end
  end

  describe '#update' do
    context '正常系' do
      context 'user_id, prompt_id, profilesを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:current_prompts) { create(:prompt, user_id: user.id) }
        let!(:new_prompts) do
          {
            about: 'new_about',
            input_example: 'new_input_example',
            output_example: 'new_output_example'
          }
        end

        it 'user_idおよびuuidでnew_promptsにあるものは更新され、それ以外は更新されないこと' do
          PromptRepository.update(current_prompts.uuid, new_prompts)
          prompts = Prompt.find_by(uuid: current_prompts.uuid)
          expect(prompts.user_id).to eq(user.id)
          expect(prompts.uuid).to eq(current_prompts.uuid)
          expect(prompts.category_id).to eq(current_prompts.category_id)
          expect(prompts.about).to eq(new_prompts[:about])
          expect(prompts.input_example).to eq(new_prompts[:input_example])
          expect(prompts.output_example).to eq(new_prompts[:output_example])
          expect(prompts.prompt).to eq(current_prompts.prompt)
          expect(prompts.generative_ai_model_id).to eq(current_prompts.generative_ai_model_id)
        end
      end
    end
  end

  describe '#delete' do
    let!(:email_creator) { Faker::Internet.email }
    let!(:password) { 'P@ssw0rd' }
    let!(:user_creator) { create(:user, email: email_creator, password:, activated: true) }
    let!(:prompts) { create(:prompt, user_id: user_creator.id) }

    context '正常系' do
      context 'user_id, prompt_idを受け取った場合' do
        it 'prompt_idに紐づくプロンプトが削除されること' do
          PromptRepository.delete(prompts.uuid)
          expect(Prompt.find_by(uuid: prompts.uuid).deleted).to eq(true)
        end
      end
    end
  end

  describe '#prompt_only' do
    context '正常系' do
      context 'user_id, prompt_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        # テーブル名とかぶるので複数形にする　
        let!(:prompts) { create(:prompt, user_id: user.id) }

        it '渡されたuser_idとuuidに紐づくプロンプトが返されること' do
          response = PromptRepository.prompt_only(prompts.uuid)
          expected = Prompt.find_by(uuid: prompts.uuid, deleted: false)
          expect(response).to eq(expected)
        end
      end
    end
  end

  describe '#prompt_detail' do
    context '正常系' do
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
      let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompts.id) }
      let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompts.id) }
      let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompts.id) }
      let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompts.id) }

      context 'user_id, prompt_idを受け取った場合（有効なプロンプトが存在する場合）' do
        let!(:prompts) { create(:prompt, user_id: user_creator.id) }
        it '渡されたuser_idとuuidに紐づくプロンプトが返されること' do
          response = PromptRepository.prompt_detail(prompts.uuid)
          expected = Prompt.left_outer_joins(:likes, :bookmarks, :category, :generative_ai_model, user: :profile)
                        .where(uuid: prompts.uuid, deleted: false)
                        .group('prompts.id', 'profiles.nickname', 'categories.name', 'generative_ai_models.name')
                        .select('prompts.*', 'profiles.nickname AS nickname', 'categories.name AS category_name', 'generative_ai_models.name AS generative_ai_model_name', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count')
                        .first
          expect(response).to eq(expected)
          expect(response.likes_count).to eq(2)
          expect(response.bookmarks_count).to eq(2)
        end
      end

      context 'user_id, prompt_idを受け取った場合（プロンプトが削除済みの場合）' do
        let!(:prompts) { create(:prompt, user_id: user_creator.id, deleted: true) }
        it 'nilが返されること' do
          response = PromptRepository.prompt_detail(prompts.uuid)
          expected = Prompt.left_outer_joins(:likes, :bookmarks, :category, :generative_ai_model, user: :profile)
                        .where(uuid: prompts.uuid, deleted: false)
                        .group('prompts.id', 'profiles.nickname', 'categories.name', 'generative_ai_models.name')
                        .select('prompts.*', 'profiles.nickname AS nickname', 'categories.name AS category_name', 'generative_ai_models.name AS generative_ai_model_name', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count')
                        .first
          expect(response).to be_nil
        end
      end
    end
  end
end
