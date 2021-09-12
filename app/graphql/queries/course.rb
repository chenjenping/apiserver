module Queries
  class Course < Queries::BaseQuery
    type Types::CourseType, null: false
    argument :id, ID, required: true

    def resolve(id:)
      ::Course.includes({ chapters: :lectures }).find(id)
    rescue ActiveRecord::RecordNotFound => _e
      GraphQL::ExecutionError.new('課程不存在')
    end
  end
end
