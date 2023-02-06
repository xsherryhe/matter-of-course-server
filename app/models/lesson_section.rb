class LessonSection < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  validates :order, presence: true
  validate :unique_order_in_lesson
  belongs_to :lesson

  attr_accessor :temp_id

  def id
    super || temp_id
  end

  private

  def unique_order_in_lesson
    return if lesson.lesson_sections
                    .reject(&:marked_for_destruction?)
                    .count { |section| section.order == order } == 1

    errors.add(:order, 'is the same as a different section')
  end
end
