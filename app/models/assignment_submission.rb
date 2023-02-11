class AssignmentSubmission < ApplicationRecord
  belongs_to :assignment, optional: true
  belongs_to :student, class_name: 'User'
  validates :student_id, uniqueness: { scope: :assignment_id, message: 'is not unique' }, if: -> { assignment.present? }
  validate :complete_with_body

  enum :completion_status, %i[incomplete complete], _default: :incomplete

  scope :with_includes, -> { includes(:assignment, { student: :profile }) }
  scope :on_page, lambda { |page = 1|
    with_includes.joins(assignment: [:lesson])
                 .order('profiles.first_name asc', 'profiles.last_name asc',
                        'lessons.order asc', 'assignments.order asc')
                 .limit(50).offset(50 * (page - 1))
  }
  scope :by_student, lambda { |student_id|
    student_id ? with_includes.where(student_id:) : with_includes
  }

  def title
    assignment&.title
  end

  def as_json(options = {})
    super({ include: [:assignment, { student: { methods: :name } }], methods: :title }.merge(options))
  end

  def as_json_with_details(options = {})
    as_json(options).merge(options.key?(:authorized) ? { authorized: options[:authorized] } : {})
  end

  def authorized_to_view?(user)
    user && (student == user || (complete? && assignment.authorized_to_edit?(user)))
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
