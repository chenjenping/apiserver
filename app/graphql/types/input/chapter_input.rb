module Types
  module Input
    class ChapterInput < Types::BaseInputObject
      argument :id, ID, required: false, default_value: nil
      argument :title, String, required: true
      argument :lectures, [Types::Input::LectureInput], required: false, default_value: []
    end
  end
end
