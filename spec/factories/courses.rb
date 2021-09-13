FactoryBot.define do
  factory :course do
    sequence(:title) { |n| "course (#{n})" }
    sequence(:instructor) { |n| "Smith (#{n})" }
    description { "course description" }
  end
end
