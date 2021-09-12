module Types
  class LectureType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :content, String, null: false
  end
end
