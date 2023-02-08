class AssignmentSubmission < ApplicationRecord
  belongs_to :assignment, optional: true
  belongs_to :student, class_name: 'User'

  enum :completion_status, %i[incomplete complete], _default: :incomplete
end
