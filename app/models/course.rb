class Course < ApplicationRecord
  has_many :chapters, -> { order(:order) }, inverse_of: :course, dependent: :destroy

  accepts_nested_attributes_for :chapters

  validates :title, :instructor, presence: true

  def update_chapters!(chapters_attributes)
    modified_chapter_mappings =  {}
    new_chapters = []
    chapters_attributes.each do |params|
      if chapter_ids.include? params[:id].to_i
        modified_chapter_mappings[params[:id]] = params
      else
        new_chapters << clear_params_ids(params)
      end
    end

    self.chapters = self.chapters.select { |chapter| modified_chapter_mappings.key?(chapter.id.to_s) }
      .map do |chapter|
        params = modified_chapter_mappings[chapter.id.to_s]
        chapter.update!(params.slice(:title, :order))
        chapter.update_lectures!(params[:lectures_attributes])
        chapter
      end

    self.chapters.create!(new_chapters)
  rescue ActiveRecord::RecordInvalid => e
    messages = e.record.errors.full_messages.map { |message| "Chapters " + message.downcase }
    raise ValidationError.new('Validation Error', messages)
  end

  private

  def clear_params_ids(params)
    params[:lectures_attributes] = params[:lectures_attributes].map { |lecture| lecture.except(:id) }
    params.except(:id)
  end
end
