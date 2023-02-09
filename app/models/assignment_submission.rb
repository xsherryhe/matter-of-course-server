class AssignmentSubmission < ApplicationRecord
  belongs_to :assignment, optional: true
  belongs_to :student, class_name: 'User'
  validates :student_id, uniqueness: { scope: :assignment_id, message: 'is not unique' }, if: -> { assignment.present? }
  validate :complete_with_body

  enum :completion_status, %i[incomplete complete], _default: :incomplete

  private

  def complete_with_body
    return unless complete? && body.blank?

    errors.add(:body, "can't be blank")
  end
end
