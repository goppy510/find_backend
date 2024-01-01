# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PromptRepository do
  describe '#self.index' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end
      let!(:user) { create(:user, activated: true) }
      let!(:contract) { create(:contract, user_id: user.id) }
      let!(:profile) { create(:profile, user_id: user.id) }

      context 'promptが1件ある場合' do
        let!(:prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
        let!(:user_1) { create(:user, activated: true) }
        let!(:user_2) { create(:user, activated: true) }
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompts.id) }
        let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompts.id) }
        let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompts.id) }

        it '1件のpromptが返されること' do
          response = PromptRepository.index(contract.id, page: 1)
          expect(response.length).to eq(1)
          expect(response[0].id).to eq(prompts.id)
          expect(response[0].uuid).to eq(prompts.uuid)
          expect(response[0].category_name).to eq(Category.find(prompts.category_id).name)
          expect(response[0].title).to eq(prompts.title)
          expect(response[0].about).to eq(prompts.about)
          expect(response[0].likes_count).to eq(2)
          expect(response[0].bookmarks_count).to eq(1)
          expect(response[0].generative_ai_model_name).to eq(GenerativeAiModel.find(prompts.generative_ai_model_id).name)
          expect(response[0].updated_at).to eq(prompts.updated_at)
        end
      end

      context 'promptが8件ある場合' do
        let!(:prompt_1) { create(:prompt, user_id: user.id, contract_id: contract.id, created_at: Time.zone.local(2022, 1, 2, 0, 0, 0)) }
        let!(:prompt_2) { create(:prompt, user_id: user.id, contract_id: contract.id, created_at: Time.zone.local(2022, 3, 2, 0, 0, 0)) }
        let!(:prompt_3) { create(:prompt, user_id: user.id, contract_id: contract.id, created_at: Time.zone.local(2022, 9, 2, 0, 0, 0)) }
        let!(:prompt_4) { create(:prompt, user_id: user.id, contract_id: contract.id, created_at: Time.zone.local(2022, 4, 2, 0, 0, 0)) }
        let!(:prompt_5) { create(:prompt, user_id: user.id, contract_id: contract.id, created_at: Time.zone.local(2022, 8, 2, 0, 0, 0)) }
        let!(:prompt_6) { create(:prompt, user_id: user.id, contract_id: contract.id, created_at: Time.zone.local(2022, 6, 2, 0, 0, 0)) }
        let!(:prompt_7) { create(:prompt, user_id: user.id, contract_id: contract.id, created_at: Time.zone.local(2022, 7, 2, 0, 0, 0)) }
        let!(:prompt_8) { create(:prompt, user_id: user.id, contract_id: contract.id, created_at: Time.zone.local(2022, 6, 20, 0, 0, 0)) }

        context '1ページ目をリクエストした場合' do
          it '6件のpromptが返されること' do
            response = PromptRepository.index(contract.id, page: 1)
            expect(response.length).to eq(6)
            expect(response[0].id).to eq(prompt_3.id)
            expect(response[1].id).to eq(prompt_5.id)
            expect(response[2].id).to eq(prompt_7.id)
            expect(response[3].id).to eq(prompt_8.id)
            expect(response[4].id).to eq(prompt_6.id)
            expect(response[5].id).to eq(prompt_4.id)
          end
        end
      end
    end
  end

  describe '#self.create' do
    context '正常系' do
      context 'user_idとpromptsを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
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
          PromptRepository.create(user.id, contract.id, prompts_for_create)
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

  describe '#self.update' do
    context '正常系' do
      context 'user_id, prompt_id, profilesを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
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

  describe '#self.destroy' do
    let!(:user_creator) { create(:user, activated: true) }
    let!(:contract) { create(:contract, user_id: user_creator.id) }
    let!(:prompts) { create(:prompt, user_id: user_creator.id, contract_id: contract.id) }

    context '正常系' do
      context 'user_id, prompt_idを受け取った場合' do
        it 'prompt_idに紐づくプロンプトが削除されること' do
          PromptRepository.destroy(prompts.uuid)
          expect(Prompt.find_by(uuid: prompts.uuid).deleted).to eq(true)
        end
      end
    end
  end

  describe '#self.show' do
    context '正常系' do
      context 'user_id, prompt_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        # テーブル名とかぶるので複数形にする　
        let!(:prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }

        it '渡されたuser_idとuuidに紐づくプロンプトが返されること' do
          response = PromptRepository.show(prompts.uuid)
          expected = Prompt.find_by(uuid: prompts.uuid, deleted: false)
          expect(response).to eq(expected)
        end
      end
    end
  end

  describe '#self.prompt_detail' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end
      let!(:user_creator) { create(:user, activated: true) }
      let!(:contract) { create(:contract, user_id: user_creator.id) }
      let!(:user_1) { create(:user, activated: true) }
      let!(:user_2) { create(:user, activated: true) }
      let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompts.id) }
      let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompts.id) }
      let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompts.id) }
      let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompts.id) }

      context 'user_id, prompt_idを受け取った場合（有効なプロンプトが存在する場合）' do
        let!(:prompts) { create(:prompt, user_id: user_creator.id, contract_id: contract.id) }
        it '渡されたuser_idとuuidに紐づくプロンプトが返されること' do
          response = PromptRepository.prompt_detail(prompts.uuid)
          expected = Prompt.left_outer_joins(:likes, :bookmarks, :category, :generative_ai_model, user: :profile)
                        .where(uuid: prompts.uuid, deleted: false)
                        .group('prompts.id', 'categories.name', 'generative_ai_models.name')
                        .select('prompts.*', 'categories.name AS category_name', 'generative_ai_models.name AS generative_ai_model_name', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count')
                        .first
          expect(response).to eq(expected)
          expect(response.likes_count).to eq(2)
          expect(response.bookmarks_count).to eq(2)
        end
      end

      context 'user_id, prompt_idを受け取った場合（プロンプトが削除済みの場合）' do
        let!(:prompts) { create(:prompt, user_id: user_creator.id, contract_id: contract.id, deleted: true) }
        it 'nilが返されること' do
          response = PromptRepository.prompt_detail(prompts.uuid)
          expected = Prompt.left_outer_joins(:likes, :bookmarks, :category, :generative_ai_model, user: :profile)
                        .where(uuid: prompts.uuid, deleted: false)
                        .group('prompts.id', 'categories.name', 'generative_ai_models.name')
                        .select('prompts.*', 'categories.name AS category_name', 'generative_ai_models.name AS generative_ai_model_name', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count')
                        .first
          expect(response).to be_nil
        end
      end
    end
  end
end
