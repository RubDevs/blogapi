require "rails_helper"
require "byebug"

RSpec.describe "Posts with authentication", type: :request do
  let!(:user) { create(:user) }  
  let!(:other_user) { create(:user) }  
  let!(:user_post) { create(:post, user_id: user.id) }  
  let!(:other_user_post) { create(:published_post, user_id: other_user.id) }  
  let!(:other_user_post_draft) { create(:post, user_id: other_user.id, published: false) }  
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}" } }
  
  describe "GET /posts/{id}" do
    context "with valid auth" do
      context "when requisiting other's author post" do
        context "when post is public" do
          before { get "/posts/#{other_user_post.id}", headers: auth_headers }

          context "payload" do
            subject { payload }
            it { is_expected.to include(:id) }
          end
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end
        end

        context " when post is a draft" do
          before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }

          context "payload" do
            subject { payload }
            it { is_expected.to include(:error) }
          end
          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:not_found) }
          end
        end
      end
    end
  end

  describe "POST /posts" do
    # con auth -> crear
    context "with valid auth" do
      it "Should create a post" do
        req_payload = {
            post: {
                title: "Titulo",
                content: "Lorem ipsum",
                published: false,
                user_id: user.id
            }
        }
        #POST http
        post "/posts", params: req_payload, headers: auth_headers
        expect(payload).to_not be_empty
        expect(payload["id"]).to_not be_nil
        expect(response).to have_http_status(:created)
      end
    end
    
    # sin auth -> !crear -> 401
    context "with invalid auth" do
      it "Should return unauthorized" do
        req_payload = {
            post: {
                title: "Titulo",
                content: "Lorem ipsum",
                published: false,
                user_id: user.id
            }
        }
        #POST http
        post "/posts", params: req_payload
        expect(payload).to_not be_empty
        expect(payload["error"]).to_not be_empty
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /posts" do
    # con auth ->
      # actualizar un post nuestro
      context "with valid auth" do
        it "Should update a post" do
          req_payload = {
              post: {
                  title: "Titulo",
                  content: "Lorem ipsum",
                  published: true,
              }
          }

          #PUT http
          put "/posts/#{user_post.id}", params: req_payload, headers: auth_headers
          expect(payload).to_not be_empty
          expect(payload["id"]).to_not be_nil
          expect(response).to have_http_status(:ok)
        end
      end
      # !actualizar un post de otro -> 401
      context "with invalid auth" do
        it "Should should return unauthorized" do
          req_payload = {
              post: {
                  title: "Titulo",
                  content: "Lorem ipsum",
                  published: true,
              }
          }

          #PUT http
          put "/posts/#{other_user_post.id}", params: req_payload, headers: auth_headers
          expect(payload).to_not be_empty
          expect(payload["error"]).to_not be_nil
          expect(response).to have_http_status(:unauthorized)
        end
      end
    # sin auth -> !actualizar -> 401
    context "with invalid auth" do
      it "Should should return unauthorized" do
        req_payload = {
            post: {
                title: "Titulo",
                content: "Lorem ipsum",
                published: true,
            }
        }

        #PUT http
        put "/posts/#{other_user_post.id}", params: req_payload
        expect(payload).to_not be_empty
        expect(payload["error"]).to_not be_nil
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  private

  def payload
    JSON.parse(response.body).with_indifferent_access
  end
end
