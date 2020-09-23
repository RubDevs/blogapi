require "rails_helper"
require "byebug"

RSpec.describe "Posts", type: :request do
    
    describe "GET /posts" do
        

        it "should return OK" do
            get '/posts' 
            payload = JSON.parse(response.body)
            expect(payload).to be_empty
            expect(response).to have_http_status(200)
        end

        describe "Search" do
            let!(:hola_rails) { create(:published_post, title: "Hola Rails") }
            let!(:hola_ruby) { create(:published_post, title: "Hola Ruby") }
            let!(:rails) { create(:published_post, title: "Rails") }
            it "Should return filtered posts" do
                get "/posts?search=Hola"
                payload = JSON.parse(response.body)
                expect(payload).to_not be_empty
                expect(payload.size).to eq(2)
                expect(payload.map { |p| p["id"] }.sort).to eq([hola_rails.id,hola_ruby.id].sort)
                expect(response).to have_http_status(200)
            end
        end
    end

    describe "With data from DB" do
        let!(:posts) { create_list(:post, 10, published: true ) }
        
        it "should return all published posts" do
            get '/posts' 
            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload.size).to eq(10)
            expect(response).to have_http_status(200)
        end
    end

    describe "GET /post/{id}" do
        let(:post) { create(:post) }

        it "Should return a post" do
            get "/posts/#{post.id}"
            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload["id"]).to eq(post.id)
            expect(payload["title"]).to eq(post.title)
            expect(payload["content"]).to eq(post.content)
            expect(payload["author"]["name"]).to eq(post.user.name)
            expect(payload["author"]["email"]).to eq(post.user.email)
            expect(payload["author"]["id"]).to eq(post.user.id)
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
            expect(payload["id"]).to_not be_nil
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
            expect(payload["id"]).to_not be_nil
            expect(response).to have_http_status(:ok)
        end

        it "Should return error on updating invalid post" do
            req_payload = {
                post: {
                    title: nil,
                    content: nil,
                    published: false,
                }
            }

            #PUT http
            put "/posts/#{article.id}", params: req_payload
            payload = JSON.parse(response.body)
            expect(payload).to_not be_empty
            expect(payload["error"]).to_not be_nil
            expect(response).to have_http_status(:unprocessable_entity)
        end
    end
end