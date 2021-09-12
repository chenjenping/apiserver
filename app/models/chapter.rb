class Chapter < ApplicationRecord
  belongs_to :course
  has_many :lectures, -> { order(:order) }, inverse_of: :chapter, dependent: :destroy

  accepts_nested_attributes_for :lectures

  validates :title, presence: true

  def update_lectures!(lectures_attributes)
    modified_lecture_mappings =  {}
    new_lectures = []
    lectures_attributes.each do |params|
      if lecture_ids.include? params[:id].to_i
        modified_lecture_mappings[params[:id]] = params
      else
        new_lectures << params.except(:id)
      end
    end

    self.lectures = self.lectures.select { |lecture| modified_lecture_mappings.key?(lecture.id.to_s) }
      .map do |lecture|
        params = modified_lecture_mappings[lecture.id.to_s]
        lecture.update!(params.slice(:title, :description, :content, :order))
        lecture
      end

    self.lectures.create!(new_lectures)
  rescue ActiveRecord::RecordInvalid => e
    messages = e.record.errors.full_messages.map { |message| "Chapters lectures " + message.downcase }
    raise ValidationError.new('Validation Error', messages)
  end
end
