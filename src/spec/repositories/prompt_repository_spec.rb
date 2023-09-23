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

  describe '#show' do
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
          response = PromptRepository.show(user.id, uuid)
          prompt = Prompt.find_by(user_id: user.id, uuid:)
          expect(response).to eq(prompt)
        end
      end
    end
  end
end
