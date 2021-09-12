module Types
  class ChapterType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false

    field :lectures, [Types::LectureType], null: false
  end
end
