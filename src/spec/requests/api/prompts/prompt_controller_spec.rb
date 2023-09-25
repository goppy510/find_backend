# frozen_string_literal: true

require 'rails_helper'

describe Api::Prompts::PromptController, type: :request do
  include SessionModule
  let!(:email) { Faker::Internet.email }
  let!(:password) { 'P@ssw0rd' }
  let!(:user) { create(:user, email:, password:, activated: true) }
  let!(:login_params) do
    {
      email:,
      password:
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

  describe 'GET /api/prompts' do
    context '正常系' do
      let(:mocked_response) { double('Response') }
      before do
        allow(PromptService).to receive(:prompt_list).with('1').and_return(mocked_response)
        get '/api/prompts', params: { page: 1 }
      end
    
      it 'jsonであること' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
      
      it 'PromptService.prompt_listがparamsの値で呼ばれること' do
        expect(PromptService).to have_received(:prompt_list).with('1')
      end
    end
    

    context '異常系' do
      context 'パラメータがなかった場合' do
        before do
          get '/api/prompts', params: {}
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end
    end
  end

  describe 'POST /api/prompts' do
    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:valid_params) do
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

        before do
          post '/api/prompts', params: valid_params,  headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end

        it 'prompt_uuidが返ってくること' do
          expect(JSON.parse(response.body)['prompt_uuid']).to_not be_nil
        end
      end
    end

    context '異常系' do
      context 'パラメータがなかった場合' do
        before do
          post '/api/prompts', params: {},  headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end
    end
  end

  describe 'GET /api/prompts/:uuid' do
    context '正常系' do
      context '正しいuser_idを受け取った場合' do
        let!(:prompt) { create(:prompt, user_id: user.id) }
        let!(:like) { create_list(:like, 3, prompt_id: prompt.id) }
        let!(:bookmark) { create_list(:bookmark, 3, prompt_id: prompt.id) }
        let!(:profile) { create(:profile, user_id: user.id) }
        let!(:category_name) { Category.find(prompt.category_id).name }
        let!(:generative_ai_model_name) { GenerativeAiModel.find(prompt.generative_ai_model_id).name }
        before do
          travel_to Time.zone.local(2021, 1, 1, 0, 0, 0)
          get "/api/prompts/#{prompt.uuid}", headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'jsonであること' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        it 'jsonでprofilesの中身を受け取ること' do
          expect(JSON.parse(response.body)).to eq(
            {
              'id' => prompt.id,
              'prompt_uuid' => prompt.uuid,
              'category' => category_name,
              'about' => prompt.about,
              'input_example' => prompt.input_example,
              'output_example' => prompt.output_example,
              'prompt' => prompt.prompt,
              'generative_ai_model' => generative_ai_model_name,
              'nickname' => profile.nickname,
              'likes_count' => like.count,
              'bookmarks_count' => bookmark.count,
              'updated_at' => prompt.updated_at.strftime('%Y-%m-%d %H:%M:%S')
            }
          )
        end
        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe 'PUT /api/prompts/:uuid' do
    context '正常系' do
      context '正しい更新用パラメータを受け取った場合' do
        let!(:current_prompts) { create(:prompt, user_id: user.id) }
        let!(:params) do
          {
            prompts: {
              about: 'new_about',
              input_example: 'new_input_example',
              output_example: 'new_output_example'
            }
          }
        end

        before do
          put "/api/prompts/#{current_prompts.uuid}", params: ,  headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end
        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end

    context '異常系' do
      context 'パラメータがなかった場合' do
        let!(:current_prompts) { create(:prompt, user_id: user.id) }
        before do
          put "/api/prompts/#{current_prompts.uuid}", params: {}
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end
    end
  end

  describe 'DELETE /api/prompts/:uuid' do
    context '正常系' do
      let!(:current_prompts) { create(:prompt, user_id: user.id) }
      context '正しい現在のパスワードと更新用パスワードを受け取った場合' do
        before do
          delete "/api/prompts/#{current_prompts.uuid}",  headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end
        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end
    # 異常系のケースが無いので省略
  end

  describe 'POST /api/prompts/:prompt_id/like' do
    describe '正常系' do
      let!(:current_prompts) { create(:prompt, user_id: user.id) }
      let!(:user_1) { create(:user, activated: true) }
      let!(:payload) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context '正しいuserの場合' do
        before do
          post "/api/prompts/#{current_prompts.id}/like", headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end
  end

  describe 'DELETE /api/prompts/:prompt_id/like' do
    describe '正常系' do
      let!(:current_prompts) { create(:prompt, user_id: user.id) }
      let!(:user_1) { create(:user, activated: true) }
      let!(:payload) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }
      let!(:like) { create(:like, user_id: user_1.id, prompt_id: current_prompts.id) }

      context '正しいuserの場合' do
        before do
          delete "/api/prompts/#{current_prompts.id}/like", headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end
  end

  describe 'POST /api/prompts/:prompt_id/bookmark' do
    describe '正常系' do
      let!(:current_prompts) { create(:prompt, user_id: user.id) }
      let!(:user_1) { create(:user, activated: true) }
      let!(:payload) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context '正しいuserの場合' do
        before do
          post "/api/prompts/#{current_prompts.id}/bookmark", headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end
  end

  describe 'DELETE /api/prompts/:prompt_id/bookmark' do
    describe '正常系' do
      let!(:current_prompts) { create(:prompt, user_id: user.id) }
      let!(:user_1) { create(:user, activated: true) }
      let!(:payload) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }
      let!(:bookmark) { create(:bookmark, user_id: user_1.id, prompt_id: current_prompts.id) }

      context '正しいuserの場合' do
        before do
          delete "/api/prompts/#{current_prompts.id}/bookmark", headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end
  end
end
