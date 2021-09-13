module Queries
  class Course < Queries::BaseQuery
    type Types::CourseType, null: false
    argument :id, ID, required: true

    def resolve(id:)
      ::Course.includes({ chapters: :lectures }).find(id)
    rescue ActiveRecord::RecordNotFound => _e
      GraphQL::ExecutionError.new("course not found")
    end
  end
end
