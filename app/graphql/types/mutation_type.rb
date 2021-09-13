module Types
  class MutationType < Types::BaseObject
    field :update_course, mutation: Mutations::UpdateCourse
    field :destroy_course, mutation: Mutations::DestroyCourse
    field :create_course, mutation: Mutations::CreateCourse
  end
end
