class Assignment < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  validates :order, presence: true
  validate :unique_order_in_lesson
  belongs_to :lesson
  has_many :assignment_submissions, dependent: :nullify

  scope :on_page, lambda { |page = 1|
    joins(:lesson).order('lessons.order asc', order: :asc).limit(30).offset(30 * (page - 1))
  }

  attr_accessor :temp_id

  def self.last_page?(page)
    count <= page * 30
  end

  def id
    super || temp_id
  end

  def course
    lesson.course
  end

  def authorized_to_edit?(user)
    lesson.authorized_to_edit?(user)
  end

  def authorized_to_view?(user)
    lesson.authorized_to_view?(user)
  end

  private

  def unique_order_in_lesson
    return if lesson.assignments
                    .reject(&:marked_for_destruction?)
                    .count { |assignment| assignment.order == order } == 1

    errors.add(:order, 'is the same as a different assignment')
  end
end
