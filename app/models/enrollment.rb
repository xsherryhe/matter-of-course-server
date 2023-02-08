class Enrollment < ApplicationRecord
  belongs_to :course
  belongs_to :student, class_name: 'User'
  validates :student_id, uniqueness: { scope: :course_id, message: 'is not unique' }

  scope :with_includes, -> { includes(student: :profile) }
  scope :roster, -> { with_includes.order('profiles.first_name asc', 'profiles.last_name asc') }

  def as_json(options = {})
    super({ include: { student: { methods: :name } } }.merge(options))
  end
end
