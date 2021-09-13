module Mutations
  class UpdateCourse < BaseMutation
    argument :id, ID, required: true
    argument :title, String, required: true
    argument :instructor, String, required: true
    argument :description, String, required: false
    argument :chapters, [Types::Input::ChapterInput], required: false

    field :course, Types::CourseType, null: true
    field :errors, [String], null: false

    def resolve(id: , title: ,instructor: ,description: nil, chapters: [])
      course = ::Course.includes({ chapters: :lectures }).find(id)
      chapters_attributes = prepare_chapters_attributes(chapters)
      ::Course.transaction do
        course.update!(title: title, instructor: instructor, description: description)
        course.update_chapters!(chapters_attributes)
      end
      course.chapters.reset
      ActiveRecord::Associations::Preloader.new.preload(course, { chapters: :lectures })

      { course: course, errors: [] }

    rescue ValidationError => e
      { errors: e.errors }
    rescue ActiveRecord::RecordInvalid
      { errors: course.errors.full_messages }
    end

    private

    def prepare_chapters_attributes(chapters)
      chapters.map.with_index do |chapter, i|
        lectures_attributes = chapter.lectures.map.with_index do |lecture, j|
          { id: lecture.id, title: lecture.title, description: lecture.description, content: lecture.content, order: j+1 }
        end

        { id: chapter.id, title: chapter.title, order: i+1, lectures_attributes: lectures_attributes }
      end
    end
  end
end
