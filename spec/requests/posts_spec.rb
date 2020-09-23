require "rails_helper"
require "byebug"

RSpec.describe "Posts", type: :request do
    
    describe "GET /posts" do
        before { get '/posts' }

        it "should return OK" do
            payload = JSON.parse(response.body)
            expect(payload).to be_empty
            expect(response).to have_http_status(200)
        end

        describe "With data from DB" do
            let!(:posts) { create_list(:post, 10, published: true ) }
            before { get '/posts' }
            it "should return all published posts" do
                payload = JSON.parse(response.body)
                expect(payload.size).to eq(posts.size)
                expect(response).to have_http_status(200)
            end
        end
    end

    describe "GET /post/{id}" do
        let(:post) { create(:post) }

        it "Should return a post" do
            get "/posts/#{post.id}"
            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload["id"]).to eq(post.id)
            expect(response).to have_http_status(200)
        end
    end

    describe "POST /posts" do
        let!(:user) { create(:user) }

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
            post "/posts", params: req_payload
            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload["id"]).to_not be_empty
            expect(response).to have_http_status(:created)
        end

        it "Should return error on invalid post" do
            req_payload = {
                post: {
                    content: "Lorem ipsum",
                    published: false,
                    user_id: user.id
                }
            }

            #POST http
            post "/posts", params: req_payload
            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload["error"]).to_not be_empty
            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe "PUT /posts/{id}" do
        let!(:article) { create(:post) }

        it "Should update a post" do
            req_payload = {
                post: {
                    title: "Titulo",
                    content: "Lorem ipsum",
                    published: true,
                }
            }

            #PUT http
            put "/posts/#{article.id}", params: req_payload
            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload["id"]).to_not be_empty
            expect(response).to have_http_status(:created)
        end

        it "Should return error on updating invalid post" do
            req_payload = {
                post: {
                    title: "Titulo",
                    published: true,
                }
            }

            #PUT http
            put "/posts/#{article.id}", params: req_payload
            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload["error"]).to_not be_empty
            expect(response).to have_http_status(:unprocessable_entity)
        end
    end
end