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
        let!(:prompts) do
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
          PromptRepository.create(user.id, prompts)
          prompt = Prompt.find_by(user_id: user.id)
          expect(prompt.user_id).to eq(user.id)
          expect(prompt.uuid).to eq(prompts[:uuid])
          expect(prompt.category_id).to eq(prompts[:category_id])
          expect(prompt.about).to eq(prompts[:about])
          expect(prompt.input_example).to eq(prompts[:input_example])
          expect(prompt.output_example).to eq(prompts[:output_example])
          expect(prompt.prompt).to eq(prompts[:prompt])
          expect(prompt.generative_ai_model_id).to eq(prompts[:generative_ai_model_id])
        end
      end
    end
  end

  describe '#update' do
    context '正常系' do
      context 'user_id, uuid, profilesを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:uuid) { 'uuid' }
        let!(:current_prompts) { create(:prompt, user_id: user.id, uuid:) }
        let!(:new_prompts) do
          {
            about: 'new_about',
            input_example: 'new_input_example',
            output_example: 'new_output_example'
          }
        end

        it 'user_idおよびuuidでnew_promptsにあるものは更新され、それ以外は更新されないこと' do
          PromptRepository.update(user.id, uuid, new_prompts)
          prompt = Prompt.find_by(user_id: user.id, uuid:)
          expect(prompt.user_id).to eq(user.id)
          expect(prompt.uuid).to eq(current_prompts.uuid)
          expect(prompt.category_id).to eq(current_prompts.category_id)
          expect(prompt.about).to eq(new_prompts[:about])
          expect(prompt.input_example).to eq(new_prompts[:input_example])
          expect(prompt.output_example).to eq(new_prompts[:output_example])
          expect(prompt.prompt).to eq(current_prompts.prompt)
          expect(prompt.generative_ai_model_id).to eq(current_prompts.generative_ai_model_id)
        end
      end
    end
  end

  describe '#prompt_only' do
    context '正常系' do
      context 'user_id, uuidを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:uuid) { 'uuid' }
        let!(:prompts) { create(:prompt, user_id: user.id, uuid:) }

        it '渡されたuser_idとuuidに紐づくプロンプトが返されること' do
          response = PromptRepository.prompt_only(uuid)
          prompt = Prompt.find_by(user_id: user.id, uuid:)
          expect(response).to eq(prompt)
        end
      end
    end
  end

  describe '#prompt_detail' do
    context '正常系' do
      context 'user_id, uuidを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email_creator) { Faker::Internet.email }
        let!(:email_1) { Faker::Internet.email }
        let!(:email_2) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user_creator) { create(:user, email: email_creator, password:, activated: true) }
        let!(:prompt) { create(:prompt, user_id: user_creator.id) }
        let!(:user_1) { create(:user, email: email_1, password:, activated: true) }
        let!(:user_2) { create(:user, email: email_2, password:, activated: true) }
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompt.id) }
        let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompt.id) }

        it '渡されたuser_idとuuidに紐づくプロンプトが返されること' do
          response = PromptRepository.prompt_detail(prompt.uuid)
          expected = Prompt.left_outer_joins(:likes, :bookmarks, :category, :generative_ai_model, user: :profile)
          .where(uuid: prompt.uuid).group('prompts.id', 'profiles.nickname', 'categories.name', 'generative_ai_models.name')
          .select('prompts.*', 'profiles.nickname AS nickname', 'categories.name AS category_name', 'generative_ai_models.name AS generative_ai_model_name', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count')
          .first
          expect(response).to eq(expected)
          expect(response.likes_count).to eq(2)
          expect(response.bookmarks_count).to eq(2)
        end
      end
    end
  end
end
