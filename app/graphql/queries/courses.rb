module Queries
  class Courses < Queries::BaseQuery
    type [Types::CourseType], null: false

    def resolve
      ::Course.includes({ chapters: :lectures }).all.order(created_at: :desc)
    end
  end
end
