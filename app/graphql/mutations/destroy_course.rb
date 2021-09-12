module Mutations
  class DestroyCourse < BaseMutation
    argument :id, ID, required: true

    field :course, Types::CourseType, null: true

    def resolve(id:)
      course = ::Course.find(id).destroy

      { course: course }
    end
  end
end
