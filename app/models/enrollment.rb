class Enrollment < ApplicationRecord
  belongs_to :course
  belongs_to :student, class_name: 'User'
  validates :student_id, uniqueness: { scope: :course_id }
end
