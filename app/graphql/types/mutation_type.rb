module Types
  class MutationType < Types::BaseObject
    field :update_course, mutation: Mutations::UpdateCourse
    field :destroy_course, mutation: Mutations::DestroyCourse
    field :create_course, mutation: Mutations::CreateCourse
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end
  end
end
