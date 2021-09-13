module Mutations
  class DestroyCourse < BaseMutation
    argument :id, ID, required: true

    field :course, Types::CourseType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      course = ::Course.find(id).destroy

      { course: course, errors: [] }
    rescue ActiveRecord::RecordNotFound => _e
      { errors: ["course not found"] }
    end
  end
end
