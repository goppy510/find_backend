# frozen_string_literal: true

require 'rails_helper'

describe Api::PromptsController, type: :request do
  include SessionModule
  let!(:user) { create(:user, activated: true) }
  let!(:payload) do
    {
      sub: user.id,
      type: 'api'
    }
  end
  let!(:auth) { generate_token(payload:) }
  let!(:token) { auth.token }
  let!(:contract) { create(:contract, user_id: user.id) }
  let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
  
  describe 'GET /api/prompts' do
    let!(:prompt) { create(:prompt, user_id: user.id, contract_id: contract.id) }
    let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
    context '正常系' do
      let(:mocked_response) { double('Response') }
      before do
        get '/api/prompts', params: { page: 1 }, headers: { 'Authorization' => "Bearer #{token}" }
      end
      it 'jsonであること' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
      it 'jsonでpromptsの中身を受け取ること' do
        expect(JSON.parse(response.body)['items']).to eq(
          [
            {
              'id' => prompt.id,
              'title' => prompt.title,
              'prompt_uuid' => prompt.uuid,
              'category' => Category.find(prompt.category_id).name,
              'about' => prompt.about,
              'input_example' => prompt.input_example,
              'output_example' => prompt.output_example,
              'prompt' => prompt.prompt,
              'generative_ai_model' => GenerativeAiModel.find(prompt.generative_ai_model_id).name,
              'likes_count' => prompt.likes.count,
              'bookmarks_count' => prompt.bookmarks.count,
              'updated_at' => prompt.updated_at.strftime('%Y-%m-%d %H:%M:%S')
            }
          ]
        )
      end
    end
    context '異常系' do
      context 'パラメータがなかった場合' do
        before do
          get '/api/prompts', params: {}, headers: { 'Authorization' => "Bearer #{token}" }
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
    let!(:permission_resource) { Resource.find_by(name: 'create_prompt') }
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
    let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
    context '正常系' do
      let!(:prompt) { create(:prompt, user_id: user.id, contract_id: contract.id) }
      let!(:like) { create_list(:like, 3, prompt_id: prompt.id) }
      let!(:bookmark) { create_list(:bookmark, 3, prompt_id: prompt.id) }
      let!(:profile) { create(:profile, user_id: user.id) }
      let!(:category_name) { Category.find(prompt.category_id).name }
      let!(:generative_ai_model_name) { GenerativeAiModel.find(prompt.generative_ai_model_id).name }
      let!(:params) { { uuid: prompt.uuid } }
      before do
        get "/api/prompts/#{prompt.uuid}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
      end
      context '正しいuser_idを受け取った場合' do
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
    let!(:permission_resource) { Resource.find_by(name: 'update_prompt') }
    context '正常系' do
      context '正しい更新用パラメータを受け取った場合' do
        let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
        let!(:params) do
          {
            uuid: current_prompts.uuid,
            prompts: {
              about: 'new_about',
              input_example: 'new_input_example',
              output_example: 'new_output_example'
            }
          }
        end

        before do
          put "/api/prompts/#{current_prompts.uuid}", params: params,  headers: { 'Authorization' => "Bearer #{token}" }
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
        let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
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
    let!(:permission_resource) { Resource.find_by(name: 'destroy_prompt') }
    context '正常系' do
      let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
      let!(:params) { { uuid: current_prompts.uuid } }
      context '正しい現在のパスワードと更新用パスワードを受け取った場合' do
        before do
          delete "/api/prompts/#{current_prompts.uuid}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
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
    let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
    let!(:user_1) { create(:user, activated: true) }
    let!(:contract_membership) { create(:contract_membership, user_id: user_1.id, contract_id: contract.id) }
    let!(:permission) { create(:permission, user_id: user_1.id, resource_id: permission_resource.id) }
    let!(:payload) do
      {
        sub: user_1.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
    let!(:params) { { prompt_id: current_prompts.id } }
    describe '正常系' do
      context '正しいuserの場合' do
        before do
          post "/api/prompts/#{current_prompts.id}/like", params: params, headers: { 'Authorization' => "Bearer #{token}" }
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
    let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
    let!(:user_1) { create(:user, activated: true) }
    let!(:contract_membership) { create(:contract_membership, user_id: user_1.id, contract_id: contract.id) }
    let!(:permission) { create(:permission, user_id: user_1.id, resource_id: permission_resource.id) }
    let!(:payload) do
      {
        sub: user_1.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
    let!(:params) { { prompt_id: current_prompts.id } }
    let!(:like) { create(:like, user_id: user_1.id, prompt_id: current_prompts.id) }
    describe '正常系' do
      context '正しいuserの場合' do
        before do
          delete "/api/prompts/#{current_prompts.id}/like", params: params, headers: { 'Authorization' => "Bearer #{token}" }
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

  describe 'GET /api/prompts/:prompt_id/like' do
    describe '正常系' do
      let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
      let!(:user_1) { create(:user, activated: true) }
      let!(:contract_membership) { create(:contract_membership, user_id: user_1.id, contract_id: contract.id) }
      let!(:permission) { create(:permission, user_id: user_1.id, resource_id: permission_resource.id) }
      let!(:payload) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }
      let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
      let!(:like) { create(:like, user_id: user_1.id, prompt_id: current_prompts.id) }
      let!(:params) { { prompt_id: current_prompts.id } }

      context '正しいuserの場合' do
        before do
          get "/api/prompts/#{current_prompts.id}/like", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end
        it 'countが返ってくること' do
          expect(JSON.parse(response.body)['count']).to eq(1)
        end
        it 'is_likedが返ってくること' do
          expect(JSON.parse(response.body)['is_liked']).to eq(true)
        end
      end
    end
  end

  describe 'POST /api/prompts/:prompt_id/bookmark' do
    describe '正常系' do
      let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
      let!(:user_1) { create(:user, activated: true) }
      let!(:contract_membership) { create(:contract_membership, user_id: user_1.id, contract_id: contract.id) }
      let!(:permission) { create(:permission, user_id: user_1.id, resource_id: permission_resource.id) }
      let!(:payload) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }
      let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
      let!(:params) { { prompt_id: current_prompts.id } }
      context '正しいuserの場合' do
        before do
          post "/api/prompts/#{current_prompts.id}/bookmark", params: params, headers: { 'Authorization' => "Bearer #{token}" }
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
      let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
      let!(:user_1) { create(:user, activated: true) }
      let!(:contract_membership) { create(:contract_membership, user_id: user_1.id, contract_id: contract.id) }
      let!(:permission) { create(:permission, user_id: user_1.id, resource_id: permission_resource.id) }
      let!(:payload) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }
      let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
      let!(:params) { { prompt_id: current_prompts.id } }
      let!(:bookmark) { create(:bookmark, user_id: user_1.id, prompt_id: current_prompts.id) }

      context '正しいuserの場合' do
        before do
          delete "/api/prompts/#{current_prompts.id}/bookmark", params: params, headers: { 'Authorization' => "Bearer #{token}" }
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

  describe 'GET /api/prompts/:prompt_id/bookmark' do
    describe '正常系' do
      let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
      let!(:user_1) { create(:user, activated: true) }
      let!(:contract_membership) { create(:contract_membership, user_id: user_1.id, contract_id: contract.id) }
      let!(:permission) { create(:permission, user_id: user_1.id, resource_id: permission_resource.id) }
      let!(:payload) do
        {
          sub: user_1.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }
      let!(:current_prompts) { create(:prompt, user_id: user.id, contract_id: contract.id) }
      let!(:params) { { prompt_id: current_prompts.id } }
      let!(:bookmark) { create(:bookmark, user_id: user_1.id, prompt_id: current_prompts.id) }

      context '正しいuserの場合' do
        before do
          get "/api/prompts/#{current_prompts.id}/bookmark", params: params, headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end
        it 'countが返ってくること' do
          expect(JSON.parse(response.body)['count']).to eq(1)
        end
        it 'is_bookmarkedが返ってくること' do
          expect(JSON.parse(response.body)['is_bookmarked']).to eq(true)
        end
      end
    end
  end
end
