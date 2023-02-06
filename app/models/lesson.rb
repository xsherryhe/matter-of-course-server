class Lesson < ApplicationRecord
  validates :title, presence: true
  validates :order, presence: true
  validates :lesson_sections, presence: true
  validate :logical_lesson_sections_order
  belongs_to :course
  has_many :lesson_sections, dependent: :destroy

  accepts_nested_attributes_for :lesson_sections, allow_destroy: true

  def as_json_with_details(options = {})
    authorized = options[:authorized]
    as_json(options)
      .merge({ lesson_sections: lesson_sections_as_json })
      .merge(options.key?(:authorized) ? { authorized: } : {})
  end

  def simplified_errors(options = {})
    super({ include: %i[lesson_sections] }.merge(options))
  end

  def lesson_sections_as_json
    lesson_sections.order(order: :asc).as_json
  end

  # TO DO: add students/enrollment
  def authorized_for?(user)
    authorized_to_edit?(user)
  end

  def authorized_to_edit?(user)
    course.authorized_to_edit?(user)
  end

  private

  def logical_lesson_sections_order
    return if lesson_sections.sort_by(&:order).map(&:order) == (1..lesson_sections.size).to_a

    errors.add(:lesson_sections, 'do not follow logical numbering order')
  end
end
