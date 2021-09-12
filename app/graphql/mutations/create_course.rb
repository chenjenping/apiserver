module Mutations
  class CreateCourse < BaseMutation
    argument :title, String, required: true
    argument :instructor, String, required: true
    argument :description, String, required: false
    argument :chapters, [Types::Input::ChapterInput], required: false

    field :course, Types::CourseType, null: true
    field :errors, [String], null: false

    def resolve(title: ,instructor: ,description: nil, chapters:)
      chapters_attributes = prepare_chapters_attributes(chapters)
      course = ::Course.new(
        title: title,
        instructor: instructor,
        description: description,
        chapters_attributes: chapters_attributes
      )

      if course.save
        { course: course, errors: [] }
      else
        { errors: course.errors.full_messages }
      end
    end

    private

    def prepare_chapters_attributes(chapters)
      chapters.map.with_index do |chapter, i|
        lectures_attributes = chapter.lectures.map.with_index do |lecture, j|
          { title: lecture.title, description: lecture.description, content: lecture.content, order: j+1 }
        end

        { title: chapter.title, order: i+1, lectures_attributes: lectures_attributes }
      end
    end
  end
end
