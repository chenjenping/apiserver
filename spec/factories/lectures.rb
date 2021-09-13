FactoryBot.define do
  factory :lecture do
    association :chapter, factory: :chapter
    sequence(:title) { |n| "lecture (#{n})" }
    description { "lecture description" }
    sequence(:title) { |n| "lecture content (#{n})" }
    sequence(:order) { |n| n }
  end
end
