require "rails_helper"

module Queries
  RSpec.describe Course, type: :request do
    describe "execute" do
      let(:query) do
        %(query {
          course(id: #{@course_id}) {
            id title instructor description chapters {
              id title lectures {
                id title description content
              }
            }
          }
        })
      end

      context "when course exists" do
        before(:each) { @course_id = create(:course, title: "test").id }
        subject { post "/graphql", params: { query: query } }

        it "returns the course" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["course"]

          expect(course["title"]).to eql("test")
        end
      end

      context "when course not found" do
        before(:each) { @course_id = 100 }
        subject { post "/graphql", params: { query: query } }

        it "returns courses" do
          subject
          data = JSON.parse(response.body)
          errors = data["errors"]

          expect(errors[0]['message']).to eql('course not found')
        end
      end
    end
  end
end
