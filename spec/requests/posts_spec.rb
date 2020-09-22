require "rails_helper"

RSpec.describe "Posts", type: :request do
    
    describe "GET /posts" do
        before { get '/posts' }

        it "should return OK" do
            payload = JSON.parse(response.body)
            expect(payload).to be_empty
            expect(response).to have_http_status(200)
        end

        describe "With data from DB" do
            before { get '/posts' }
            let(:posts) { create_list(:post, 10, published: true ) }

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
            expect(payload["id"]).to_eq(post.id)
            expect(response).to have_http_status(200)
        end
    end
end