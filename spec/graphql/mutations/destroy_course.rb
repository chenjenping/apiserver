require "rails_helper"

module Mutations
  RSpec.describe DestroyCourse, type: :request do
    describe "execute" do
      let(:query) do
        %(mutation {
          destroyCourse(
            input: {
              id: #{@course_id}
            }
          ) {
            course {
              id title instructor description chapters {
                id title lectures {
                  id title description content
                }
              }
            }
            errors
          }
        })
      end
      context "when course can be destroyed" do
        before(:each) { @course_id = create(:course, title: "test").id }
        subject { post "/graphql", params: { query: query } }

        it "destroys the course" do
          expect { subject }.to change { Course.count }.from(1).to(0)
        end

        it "returns the course" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["destroyCourse"]["course"]

          expect(course["id"].to_i).to eql(@course_id)
          expect(course["title"]).to eql("test")
        end

        it "gets empty errors" do
          subject
          data = JSON.parse(response.body)
          expect(data["data"]["destroyCourse"]["errors"].size).to eql(0)
        end
      end

      context "when course not found" do
        before(:each) { @course_id = 100 }
        subject { post "/graphql", params: { query: query } }

        it "returns errors" do
          subject
          data = JSON.parse(response.body)
          errors = data["data"]["destroyCourse"]["errors"]

          expect(errors.include?("course not found")).to eql(true)
        end
      end
    end
  end
end
