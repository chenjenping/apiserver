require "rails_helper"

module Mutations
  RSpec.describe UpdateCourse, type: :request do
    describe "execute" do
      let(:original_query) do
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

      context "when course input is valid" do
        before(:each) { post "/graphql", params: { query: original_query } }
        let(:update_query) do
          %(mutation {
            updateCourse(
              input: {
                id: 1
                title: "Course 1 updated"
                instructor: "Instructor 1 updated"
                description: "this is updated description"
                chapters: [
                  { id: 1, title: "Chapter 1 updated", lectures: [
                    { id: 1, title: "Lecture 1 updated", description: "this is updated lecture description", content: "this is updated text content for lecture 1" }
                    { id: 2, title: "Lecture 2", description: "", content: "this is text content for lecture 2"}]
                  }
                  { id: 2, title: "Chapter 2", lectures: [] }
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
        subject { post "/graphql", params: { query: update_query } }

        it "updates course" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["updateCourse"]["course"]

          expect(course["title"]).to eql("Course 1 updated")
          expect(course["instructor"]).to eql("Instructor 1 updated")
          expect(course["description"]).to eql("this is updated description")
          expect(course["chapters"].size).to eql(2)
        end

        it "updates chapter 1" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["updateCourse"]["course"]
          chapter1 = course["chapters"][0]

          expect(chapter1["title"]).to eql("Chapter 1 updated")
          expect(chapter1["lectures"].size).to eql(2)
        end

        it "does not update chapter 2" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["updateCourse"]["course"]
          chapter2 = course["chapters"][1]

          expect(chapter2["title"]).to eql("Chapter 2")
          expect(chapter2["lectures"].size).to eql(0)
        end

        it "updates lecture 1" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["updateCourse"]["course"]
          lecture1 = course["chapters"][0]["lectures"][0]

          expect(lecture1["title"]).to eql("Lecture 1 updated")
          expect(lecture1["description"]).to eql("this is updated lecture description")
          expect(lecture1["content"]).to eql("this is updated text content for lecture 1")
        end

        it "does not update lecture 2" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["updateCourse"]["course"]
          lecture2 = course["chapters"][0]["lectures"][1]

          expect(lecture2["title"]).to eql("Lecture 2")
          expect(lecture2["description"]).to eql("")
          expect(lecture2["content"]).to eql("this is text content for lecture 2")
        end

        it "gets empty errors" do
          subject
          data = JSON.parse(response.body)
          expect(data["data"]["updateCourse"]["errors"].size).to eql(0)
        end
      end

      context "when chapter order changed" do
        before(:each) { post "/graphql", params: { query: original_query } }
        let(:update_query) do
          %(mutation {
            updateCourse(
              input: {
                id: 1
                title: "Course 1 updated"
                instructor: "Instructor 1 updated"
                description: "this is updated description"
                chapters: [
                  { id: 2, title: "Chapter 2", lectures: [] }
                  { id: 1, title: "Chapter 1 updated", lectures: [
                    { id: 1, title: "Lecture 1 updated", description: "this is updated lecture description", content: "this is updated text content for lecture 1" }
                    { id: 2, title: "Lecture 2", description: "", content: "this is text content for lecture 2"}]
                  }
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
        subject { post "/graphql", params: { query: update_query } }

        it "updates course" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["updateCourse"]["course"]

          expect(course["title"]).to eql("Course 1 updated")
          expect(course["instructor"]).to eql("Instructor 1 updated")
          expect(course["description"]).to eql("this is updated description")
          expect(course["chapters"].size).to eql(2)
        end

        it "updates chapters order" do
          subject
          data = JSON.parse(response.body)
          course = data["data"]["updateCourse"]["course"]
          chapter1 = course["chapters"][1]
          chapter2 = course["chapters"][0]

          expect(chapter1["title"]).to eql("Chapter 1 updated")
          expect(chapter1["lectures"].size).to eql(2)
          expect(chapter2["title"]).to eql("Chapter 2")
        end

        it "gets empty errors" do
          subject
          data = JSON.parse(response.body)
          expect(data["data"]["updateCourse"]["errors"].size).to eql(0)
        end
      end

      context "when course input is not valid" do
        before(:each) { post "/graphql", params: { query: original_query } }
        let(:update_query) do
          %(mutation {
            updateCourse(
              input: {
                id: 1
                title: ""
                instructor: ""
                description: ""
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
        subject { post "/graphql", params: { query: update_query } }

        it "returns errors" do
          subject
          data = JSON.parse(response.body)
          errors = data["data"]["updateCourse"]["errors"]

          expect(errors.include?("Title can't be blank")).to eql(true)
          expect(errors.include?("Instructor can't be blank")).to eql(true)
        end
      end

      context "when chapter title is not valid" do
        before(:each) { post "/graphql", params: { query: original_query } }
        let(:update_query) do
          %(mutation {
            updateCourse(
              input: {
                id: 1
                title: "Chapter 1 updated"
                instructor: "Instructor 1 updated"
                description: ""
                chapters: [
                  { id: 1, title: "" }
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
        subject { post "/graphql", params: { query: update_query } }

        it "returns errors" do
          subject
          data = JSON.parse(response.body)
          errors = data["data"]["updateCourse"]["errors"]

          expect(errors.include?("Chapters title can't be blank")).to eql(true)
        end
      end

      context "when lecture input is not valid" do
        before(:each) { post "/graphql", params: { query: original_query } }
        let(:update_query) do
          %(mutation {
            updateCourse(
              input: {
                id: 1
                title: "Chapter 1 updated"
                instructor: "Instructor 1 updated"
                description: ""
                chapters: [
                  { id: 1, title: "Chapter 1 updated", lectures: [
                    { id: 1, title: "", description: "", content: "" }
                    { id: 2, title: "Lecture 2", description: "", content: "this is text content for lecture 2"}]
                  }
                  { id: 2, title: "Chapter 2", lectures: [] }
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
        subject { post "/graphql", params: { query: update_query } }

        it "returns errors" do
          subject
          data = JSON.parse(response.body)
          errors = data["data"]["updateCourse"]["errors"]

          expect(errors.include?("Chapters lectures title can't be blank")).to eql(true)
          expect(errors.include?("Chapters lectures content can't be blank")).to eql(true)
        end
      end
    end
  end
end
