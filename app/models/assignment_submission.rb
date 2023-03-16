class AssignmentSubmission < ApplicationRecord
  before_validation :set_completed_at
  validates :student_id, uniqueness: { scope: :assignment_id, message: 'is not unique' }, if: -> { assignment.present? }
  validate :complete_with_body_and_completed_at
  belongs_to :assignment, optional: true
  belongs_to :student, class_name: 'User'
  has_many :comments, as: :commentable, dependent: :destroy

  enum :completion_status, %i[incomplete complete], _default: :incomplete

  scope :with_includes, -> { includes(:assignment, { student: :profile }) }
  scope :on_page, lambda { |page = 1|
    with_includes.joins(assignment: [:lesson])
                 .order('profiles.first_name asc', 'profiles.last_name asc',
                        'lessons.order asc', 'assignments.order asc')
                 .limit(20).offset(20 * (page - 1))
  }
  scope :by_student, lambda { |student_id|
    student_id ? with_includes.where(student_id:) : with_includes
  }
  scope :by_course, lambda { |course_id|
    return with_includes unless course_id

    with_includes.joins(assignment: { lesson: :course })
                 .where('course.id' => course_id)
  }

  def self.last_page?(page)
    count <= page * 20
  end

  def title
    assignment&.title
  end

  def course
    assignment&.course
  end

  def completion_date
    return unless completed_at.present?

    completed_at.localtime.strftime(DateTime.current - 1.year < completed_at ? '%-m/%-d' : '%-m/%-d/%y')
  end

  def as_json(options = {})
    super({ include: [:assignment, { student: { methods: %i[name avatar_url] } }],
            methods: %i[title completion_date] }.merge(options))
  end

  def as_json_with_details(options = {})
    return as_json(options) unless options.key?(:user)

    as_json(options)
      .merge({ owned: owned?(options[:user]),
               authorized: authorized_to_edit?(options[:user]),
               assignment_authorized: assignment_authorized?(options[:user]) })
  end

  def owned?(user)
    user && student == user
  end

  def assignment_authorized?(user)
    assignment&.authorized_to_view?(user)
  end

  def authorized_to_view?(user)
    owned?(user) || (complete? && assignment.authorized_to_edit?(user))
  end

  def authorized_to_edit?(user)
    owned?(user) && assignment_authorized?(user)
  end

  def accepting_comments?
    complete?
  end

  private

  def set_completed_at
    return unless complete? && completed_at.blank?

    self.completed_at = DateTime.current
  end

  def complete_with_body_and_completed_at
    return unless complete?

    errors.add(:body, "can't be blank") if body.blank?
    errors.add(:completed_at, "can't be blank") if completed_at.blank?
  end
end
