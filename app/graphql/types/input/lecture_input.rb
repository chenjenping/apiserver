module Types
  module Input
    class LectureInput < Types::BaseInputObject
      argument :id, ID, required: false, default_value: nil
      argument :title, String, required: true
      argument :description, String, required: false
      argument :content, String, required: true
    end
  end
end
