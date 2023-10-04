# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PromptService do
  include SessionModule

  describe '#self.prompt_list' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end
      let!(:user) { create(:user, activated: true) }

      context 'pageを指定し、かつ、レコードが1つだった場合' do
        let!(:prompts) { create(:prompt, user_id: user.id) }
        let!(:profile) { create(:profile, user_id: user.id) }
        let!(:user_1) { create(:user, activated: true) }
        let!(:user_2) { create(:user, activated: true) }
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompts.id) }
        let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompts.id) }
        let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompts.id) }
        let!(:category_name) { Category.find(prompts.category_id).name }
        let!(:generative_ai_model_name) { GenerativeAiModel.find(prompts.generative_ai_model_id).name }

        it 'promptsのデータがハッシュで返されること' do
          res = PromptService.prompt_list(1)
          expect(res[:items][0][:id]).to eq(prompts.id)
          expect(res[:items][0][:prompt_uuid]).to eq(prompts.uuid)
          expect(res[:items][0][:category]).to eq(category_name)
          expect(res[:items][0][:about]).to eq(prompts.about)
          expect(res[:items][0][:generative_ai_model]).to eq(generative_ai_model_name)
          expect(res[:items][0][:nickname]).to eq(profile.nickname)
          expect(res[:items][0][:likes_count]).to eq(2)
          expect(res[:items][0][:bookmarks_count]).to eq(1)
        end
      end

      context 'pageを指定し、かつ、レコードが8件あった場合' do
        let!(:prompt_1) { create(:prompt, user_id: user.id, created_at: Time.zone.local(2022, 1, 2, 0, 0, 0)) }
        let!(:prompt_2) { create(:prompt, user_id: user.id, created_at: Time.zone.local(2022, 3, 2, 0, 0, 0)) }
        let!(:prompt_3) { create(:prompt, user_id: user.id, created_at: Time.zone.local(2022, 9, 2, 0, 0, 0)) }
        let!(:prompt_4) { create(:prompt, user_id: user.id, created_at: Time.zone.local(2022, 4, 2, 0, 0, 0)) }
        let!(:prompt_5) { create(:prompt, user_id: user.id, created_at: Time.zone.local(2022, 8, 2, 0, 0, 0)) }
        let!(:prompt_6) { create(:prompt, user_id: user.id, created_at: Time.zone.local(2022, 6, 2, 0, 0, 0)) }
        let!(:prompt_7) { create(:prompt, user_id: user.id, created_at: Time.zone.local(2022, 7, 2, 0, 0, 0)) }
        let!(:prompt_8) { create(:prompt, user_id: user.id, created_at: Time.zone.local(2022, 6, 20, 0, 0, 0)) }

        context 'pageが1の場合' do
          it 'created_atの降順で返ってくること' do
            res = PromptService.prompt_list(1)
            expect(res[:items][0][:id]).to eq(prompt_3.id)
            expect(res[:items][1][:id]).to eq(prompt_5.id)
            expect(res[:items][2][:id]).to eq(prompt_7.id)
            expect(res[:items][3][:id]).to eq(prompt_8.id)
            expect(res[:items][4][:id]).to eq(prompt_6.id)
            expect(res[:items][5][:id]).to eq(prompt_4.id)
          end

          it 'total_countが6であること' do
            res = PromptService.prompt_list(1)
            expect(res[:total_count]).to eq(6)
          end
        end

        context 'pageが2の場合' do
          it 'created_atの降順で返ってくること' do
            res = PromptService.prompt_list(2)
            expect(res[:items][0][:id]).to eq(prompt_2.id)
            expect(res[:items][1][:id]).to eq(prompt_1.id)
          end

          it 'total_countが2であること' do
            res = PromptService.prompt_list(2)
            expect(res[:total_count]).to eq(2)
          end
        end
      end
    end

    context '異常系' do
      context 'pageがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.prompt_list(nil) }.to raise_error(ArgumentError, 'pageがありません')
        end
      end
    end
  end

  describe '#self.create' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:prompts) do
          {
            prompts: {
              about: 'about',
              title: 'title',
              input_example: 'input_example',
              output_example: 'output_example',
              prompt: 'prompt',
              generative_ai_model_id: 1,
              category_id: 2
            }
          }
        end
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'promptsに登録されること' do
          PromptService.create(token, prompts)
          actual_data = Prompt.find_by(user_id: user.id)
          expect(actual_data.title).to eq(prompts[:prompts][:title])
          expect(actual_data.about).to eq(prompts[:prompts][:about])
          expect(actual_data.input_example).to eq(prompts[:prompts][:input_example])
          expect(actual_data.output_example).to eq(prompts[:prompts][:output_example])
          expect(actual_data.prompt).to eq(prompts[:prompts][:prompt])
          expect(actual_data.generative_ai_model_id).to eq(prompts[:prompts][:generative_ai_model_id])
          expect(actual_data.category_id).to eq(prompts[:prompts][:category_id])
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, email:, password:, activated: true) }
      let!(:prompts) do
        {
          prompts: {
            about: 'about',
            title: 'title',
            input_example: 'input_example',
            output_example: 'output_example',
            prompt: 'prompt',
            generative_ai_model_id: 1,
            category_id: 2
          }
        }
      end

      context 'tokenがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.create(nil, prompts) }.to raise_error(ArgumentError, 'tokenがありません')
        end
      end

      context 'promptsがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.create(user.id, {}) }.to raise_error(ArgumentError, 'promptsがありません')
        end
      end
    end
  end

  describe '#self.update' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:current_prompts) { create(:prompt, user_id: user.id) }
        let!(:new_prompts) do
          {
            prompts: {
              about: 'new_about',
              input_example: 'new_input_example',
              output_example: 'new_output_example'
            }
          }
        end
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'userのidでnew_promptsにあるものは更新され、それ以外は更新されないこと' do
          PromptService.update(token, current_prompts.uuid, new_prompts)
          prompt = Prompt.find_by(uuid: current_prompts.uuid, deleted: false)
          expect(prompt.user_id).to eq(user.id)
          expect(prompt.uuid).to eq(current_prompts.uuid)
          expect(prompt.category_id).to eq(current_prompts.category_id)
          expect(prompt.about).to eq(new_prompts[:prompts][:about])
          expect(prompt.input_example).to eq(new_prompts[:prompts][:input_example])
          expect(prompt.output_example).to eq(new_prompts[:prompts][:output_example])
          expect(prompt.prompt).to eq(current_prompts.prompt)
          expect(prompt.generative_ai_model_id).to eq(current_prompts.generative_ai_model_id)
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, password:, activated: true) }
      let!(:current_prompts) { create(:prompt, user_id: user.id) }
      let!(:new_prompts) do
        {
          prompts: {
            about: 'new_about',
            input_example: 'new_input_example',
            output_example: 'new_output_example'
          }
        }
      end

      context 'tokenがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.update(nil, current_prompts.uuid, new_prompts) }.to raise_error(ArgumentError, 'tokenがありません')
        end
      end

      context 'prompt_uuidがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.update(user.id, nil, new_prompts) }.to raise_error(ArgumentError, 'uuidがありません')
        end
      end

      context 'promptsがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.update(user.id, current_prompts.id, nil) }.to raise_error(ArgumentError, 'promptsがありません')
        end
      end
    end
  end

  describe '#self.delete' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:current_prompts) { create(:prompt, user_id: user.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'promptが削除されること' do
          PromptService.delete(token, current_prompts.uuid)
          prompt = Prompt.find_by(uuid: current_prompts.uuid, deleted: false)
          expect(prompt).to eq(nil)
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, password:, activated: true) }
      let!(:current_prompts) { create(:prompt, user_id: user.id) }

      context 'tokenがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.delete(nil, current_prompts.id) }.to raise_error(ArgumentError, 'tokenがありません')
        end
      end

      context 'prompt_uuidがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.delete(user.id, nil) }.to raise_error(ArgumentError, 'uuidがありません')
        end
      end
    end
  end

  describe '#self.show' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:password) { 'P@ssw0rd' }
        let!(:user_creator) { create(:user, password:, activated: true) }
        let!(:profile_creator) { create(:profile, user_id: user_creator.id) }
        let!(:user_1) { create(:user, password:, activated: true) }
        let!(:user_2) { create(:user, password:, activated: true) }
        let!(:prompts) { create(:prompt, user_id: user_creator.id) }
        let!(:category_name) { Category.find(prompts.category_id).name }
        let!(:generative_ai_model_name) { GenerativeAiModel.find(prompts.generative_ai_model_id).name }
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompts.id) }
        let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompts.id) }
        let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompts.id) }
        let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompts.id) }
        let!(:payload) do
          {
            sub: user_creator.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'promptsのデータがハッシュで返されること' do
          res = PromptService.show(token, prompts.uuid)
          expect(res[:id]).to eq(prompts.id)
          expect(res[:prompt_uuid]).to eq(prompts.uuid)
          expect(res[:category]).to eq(category_name)
          expect(res[:about]).to eq(prompts.about)
          expect(res[:input_example]).to eq(prompts.input_example)
          expect(res[:output_example]).to eq(prompts.output_example)
          expect(res[:prompt]).to eq(prompts.prompt)
          expect(res[:generative_ai_model]).to eq(generative_ai_model_name)
          expect(res[:nickname]).to eq(profile_creator.nickname)
          expect(res[:likes_count]).to eq(2)
          expect(res[:bookmarks_count]).to eq(2)
          expect(res[:updated_at]).to eq(prompts.updated_at.strftime('%Y-%m-%d %H:%M:%S'))
        end
      end
    end

    context '異常系' do
      let!(:password) { 'P@ssw0rd' }
      let!(:user_creator) { create(:user, password:, activated: true) }
      let!(:prompt) { create(:prompt, user_id: user_creator.id) }
      let!(:payload) do
        {
          sub: user_creator.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      context 'tokenがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.show(nil, prompt.uuid) }.to raise_error(ArgumentError, 'tokenがありません')
        end
      end

      context 'prompt_uuidがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { PromptService.show(token, nil) }.to raise_error(ArgumentError, 'uuidがありません')
        end
      end
    end
  end

  describe '#self.like' do
    let!(:password) { 'P@ssw0rd' }
    let!(:user_1) { create(:user, password:, activated: true) }
    let!(:user_2) { create(:user, password:, activated: true) }
    let!(:prompt) { create(:prompt) }

    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        let!(:payload_1) do
          {
            sub: user_1.id,
            type: 'api'
          }
        end
        let!(:auth_1) { generate_token(payload: payload_1) }
        let!(:token_1) { auth_1.token }
        let!(:payload_2) do
          {
            sub: user_2.id,
            type: 'api'
          }
        end
        let!(:auth_2) { generate_token(payload: payload_2) }
        let!(:token_2) { auth_2.token }

        it 'likeが作成されること' do
          PromptService.like(token_1, prompt.id)
          PromptService.like(token_2, prompt.id)
          like_1 = Like.find_by(user_id: user_1.id, prompt_id: prompt.id)
          expect(like_1.user_id).to eq(user_1.id)
          expect(like_1.prompt_id).to eq(prompt.id)
          like_2 = Like.find_by(user_id: user_2.id, prompt_id: prompt.id)
          expect(like_2.user_id).to eq(user_2.id)
          expect(like_2.prompt_id).to eq(prompt.id)
        end
      end
    end
  end

  describe '#self.dislike' do
    let!(:user_1) { create(:user, activated: true) }
    let!(:user_2) { create(:user, activated: true) }
    let!(:prompt) { create(:prompt) }

    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        let!(:payload_1) do
          {
            sub: user_1.id,
            type: 'api'
          }
        end
        let!(:auth_1) { generate_token(payload: payload_1) }
        let!(:token_1) { auth_1.token }
        let!(:payload_2) do
          {
            sub: user_2.id,
            type: 'api'
          }
        end
        let!(:auth_2) { generate_token(payload: payload_2) }
        let!(:token_2) { auth_2.token }
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompt.id) }

        it 'likeが削除されること' do
          PromptService.dislike(token_1, prompt.id)
          like = Like.where(prompt_id: prompt.id)
          expect(like.length).to eq(1)
        end
      end
    end
  end

  describe '#self.like_count' do
    let!(:user_creator) { create(:user, activated: true) }
    let!(:payload) do
      {
        sub: user_creator.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload: payload) }
    let!(:token) { auth.token }

    let!(:user_1) { create(:user, activated: true) }
    let!(:user_2) { create(:user, activated: true) }
    let!(:prompt) { create(:prompt) }

    let!(:payload_1) do
      {
        sub: user_1.id,
        type: 'api'
      }
    end
    let!(:auth_1) { generate_token(payload: payload_1) }
    let!(:token_1) { auth_1.token }
    let!(:payload_2) do
      {
        sub: user_2.id,
        type: 'api'
      }
    end
    let!(:auth_2) { generate_token(payload: payload_2) }
    let!(:token_2) { auth_2.token }

    context '正常系' do
      context 'いいねが1件の場合' do
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompt.id) }

        it 'いいね数が1であること' do
          res = PromptService.like_count(token, prompt.id)
          expect(res).to eq(1)
        end
      end

      context 'いいねが2件の場合' do
        let!(:like_1) { create(:like, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:like_2) { create(:like, user_id: user_2.id, prompt_id: prompt.id) }

        it 'いいね数が2であること' do
          res = PromptService.like_count(token, prompt.id)
          expect(res).to eq(2)
        end
      end
    end
  end

  describe '#self.bookmark' do
    let!(:password) { 'P@ssw0rd' }
    let!(:user_1) { create(:user, password:, activated: true) }
    let!(:user_2) { create(:user, password:, activated: true) }
    let!(:prompt) { create(:prompt) }

    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        let!(:payload_1) do
          {
            sub: user_1.id,
            type: 'api'
          }
        end
        let!(:auth_1) { generate_token(payload: payload_1) }
        let!(:token_1) { auth_1.token }
        let!(:payload_2) do
          {
            sub: user_2.id,
            type: 'api'
          }
        end
        let!(:auth_2) { generate_token(payload: payload_2) }
        let!(:token_2) { auth_2.token }

        it 'bookmarkが作成されること' do
          PromptService.bookmark(token_1, prompt.id)
          PromptService.bookmark(token_2, prompt.id)
          bookmark_1 = Bookmark.find_by(user_id: user_1.id, prompt_id: prompt.id)
          expect(bookmark_1.user_id).to eq(user_1.id)
          expect(bookmark_1.prompt_id).to eq(prompt.id)
          bookmark_2 = Bookmark.find_by(user_id: user_2.id, prompt_id: prompt.id)
          expect(bookmark_2.user_id).to eq(user_2.id)
          expect(bookmark_2.prompt_id).to eq(prompt.id)
        end
      end
    end
  end

  describe '#self.disbookmark' do
    let!(:password) { 'P@ssw0rd' }
    let!(:user_1) { create(:user, password:, activated: true) }
    let!(:user_2) { create(:user, password:, activated: true) }
    let!(:prompt) { create(:prompt) }

    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        let!(:payload_1) do
          {
            sub: user_1.id,
            type: 'api'
          }
        end
        let!(:auth_1) { generate_token(payload: payload_1) }
        let!(:token_1) { auth_1.token }
        let!(:payload_2) do
          {
            sub: user_2.id,
            type: 'api'
          }
        end
        let!(:auth_2) { generate_token(payload: payload_2) }
        let!(:token_2) { auth_2.token }
        let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompt.id) }
        let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompt.id) }

        it 'bookmarkが削除されること' do
          PromptService.disbookmark(token_1, prompt.id)
          bookmark = Bookmark.where(prompt_id: prompt.id)
          expect(bookmark.length).to eq(1)
        end
      end
    end

    describe '#self.bookmark_count' do
      let!(:user_creator) { create(:user, activated: true) }
      let!(:payload) do
        {
          sub: user_creator.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload: payload) }
      let!(:token) { auth.token }
  
      let!(:user_1) { create(:user, activated: true) }
      let!(:user_2) { create(:user, activated: true) }
      let!(:prompt) { create(:prompt) }
  
      let!(:payload_1) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth_1) { generate_token(payload: payload_1) }
      let!(:token_1) { auth_1.token }
      let!(:payload_2) do
        {
          sub: user_2.id,
          type: 'api'
        }
      end
      let!(:auth_2) { generate_token(payload: payload_2) }
      let!(:token_2) { auth_2.token }
  
      context '正常系' do
        context 'ブックマークが1件の場合' do
          let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompt.id) }
  
          it 'ブックマーク数が1であること' do
            res = PromptService.bookmark_count(token_1, prompt.id)
            expect(res[:count]).to eq(1)
          end

          it 'trueを返すこと' do
            res = PromptService.bookmark_count(token_1, prompt.id)
            expect(res[:is_bookmarked]).to eq(true)
          end
        end
  
        context 'ブックマークが2件の場合' do
          let!(:bookmark_1) { create(:bookmark, user_id: user_1.id, prompt_id: prompt.id) }
          let!(:bookmark_2) { create(:bookmark, user_id: user_2.id, prompt_id: prompt.id) }
  
          it 'ブックマーク数が2であること' do
            res = PromptService.bookmark_count(token, prompt.id)
            expect(res[:count]).to eq(2)
          end

          it 'falseを返すこと' do
            res = PromptService.bookmark_count(token, prompt.id)
            expect(res[:is_bookmarked]).to eq(false)
          end
        end
      end
    end
  end
end
