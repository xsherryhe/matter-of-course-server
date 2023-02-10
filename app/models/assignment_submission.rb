class AssignmentSubmission < ApplicationRecord
  belongs_to :assignment, optional: true
  belongs_to :student, class_name: 'User'
  validates :student_id, uniqueness: { scope: :assignment_id, message: 'is not unique' }, if: -> { assignment.present? }
  validate :complete_with_body

  enum :completion_status, %i[incomplete complete], _default: :incomplete

  def as_json_with_details(options = {})
    as_json({ include: [:assignment, { student: { methods: :name } }] }.merge(options))
      .merge(options.key?(:authorized) ? { authorized: options[:authorized] } : {})
  end

  def authorized_to_view?(user)
    user && (student == user || (complete? && assignment.lesson.authorized_to_edit?(user)))
  end

  def authorized_to_edit?(user)
    user && student == user
  end

  private

  def complete_with_body
    return unless complete? && body.blank?

    errors.add(:body, "can't be blank")
  end
end
