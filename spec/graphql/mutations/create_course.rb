require "rails_helper"

module Mutations
  RSpec.describe CreateCourse, type: :request do
    describe "execute" do
      context "when course input is valid" do
        let(:query) do
          %(mutation {
            createCourse(
              input: {
                title: "Course 1"
                instructor: "Instructor 1"
                description: "this is description"
                chapters: [
                  { title: "Chapter 1", lectures: [
                    { title: "Lecture 1", description: "this is lecture description", content: "this is text content for lecture 1" }
                    { title: "Lecture 2", description: "", content: "this is text content for lecture 2"}]
                  }
                  { title: "Chapter 2", lectures: [] }
                ]
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
        subject { post "/graphql", params: { query: query } }

        it "creates a course" do
          expect { subject }.to change { Course.count }.from(0).to(1)
        end

        it "returns the course" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["createCourse"]["course"]

          expect(course["title"]).to eql("Course 1")
          expect(course["instructor"]).to eql("Instructor 1")
          expect(course["description"]).to eql("this is description")
          expect(course["chapters"].size).to eql(2)

          chapter1 = course["chapters"][0]
          expect(chapter1["title"]).to eql("Chapter 1")
          expect(chapter1["lectures"].size).to eql(2)

          lecture1 = chapter1["lectures"][0]
          expect(lecture1["title"]).to eql("Lecture 1")
          expect(lecture1["description"]).to eql("this is lecture description")
          expect(lecture1["content"]).to eql("this is text content for lecture 1")

          lecture2 = chapter1["lectures"][1]
          expect(lecture2["title"]).to eql("Lecture 2")
          expect(lecture2["description"]).to eql("")
          expect(lecture2["content"]).to eql("this is text content for lecture 2")

          chapter2 = course["chapters"][1]
          expect(chapter2["title"]).to eql("Chapter 2")
          expect(chapter2["lectures"].size).to eql(0)
        end

        it "gets empty errors" do
          subject
          data = JSON.parse(response.body)
          expect(data["data"]["createCourse"]["errors"].size).to eql(0)
        end
      end

      context "when course input is not valid" do
        let(:query) do
          %(mutation {
            createCourse(
              input: {
                title: ""
                instructor: ""
                description: ""
                chapters: [
                  { title: "Chapter 1", lectures: [
                    { title: "", description: "", content: "" }]
                  }
                  { title: "" }
                ]
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
        subject { post "/graphql", params: { query: query } }

        it "does not create a course" do
          subject
          expect(Course.count).to eql(0)
        end

        it "returns errors" do
          subject
          data = JSON.parse(response.body)
          errors = data["data"]["createCourse"]["errors"]

          expect(errors.include?("Title can't be blank")).to eql(true)
          expect(errors.include?("Instructor can't be blank")).to eql(true)
          expect(errors.include?("Chapters title can't be blank")).to eql(true)
          expect(errors.include?("Chapters lectures title can't be blank")).to eql(true)
          expect(errors.include?("Chapters lectures content can't be blank")).to eql(true)
        end
      end
    end
  end
end
