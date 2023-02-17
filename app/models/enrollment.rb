class Enrollment < ApplicationRecord
  belongs_to :course
  belongs_to :student, class_name: 'User'
  validates :student_id, uniqueness: { scope: :course_id, message: 'is not unique' }

  scope :with_includes, -> { includes(student: :profile) }
  scope :on_page, ->(page = 1) { with_includes.limit(50).offset(50 * (page - 1)) }
  scope :roster, -> { order('profiles.first_name asc', 'profiles.last_name asc') }

  def as_json(options = {})
    super({ include: { student: { methods: :name } } }.merge(options))
  end

  def authorized_to_edit?(user)
    user == student || course.authorized_to_edit?(user)
  end
end
