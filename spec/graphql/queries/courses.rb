require "rails_helper"

module Queries
  RSpec.describe Courses, type: :request do
    describe "execute" do
      let(:query) do
        %(query {
          courses {
            id title instructor description chapters {
              id title lectures {
                id title description content
              }
            }
          }
        })
      end

      context "when there are no courses" do
        subject { post "/graphql", params: { query: query } }

        it "returns empty courses" do
          subject
          data = JSON.parse(response.body)
          courses = data["data"]["courses"]

          expect(courses.size).to eql(0)
        end
      end

      context "when there are courses" do
        before(:each) { create_list(:course, 2) }
        subject { post "/graphql", params: { query: query } }

        it "returns courses" do
          subject
          data = JSON.parse(response.body)
          courses = data["data"]["courses"]

          expect(courses.size).to eql(2)
        end
      end
    end
  end
end
