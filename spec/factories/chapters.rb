FactoryBot.define do
  factory :chapter do
    association :course, factory: :course
    sequence(:title) { |n| "chapter (#{n})" }
    sequence(:order) { |n| n }
  end
end
