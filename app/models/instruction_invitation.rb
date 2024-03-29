class InstructionInvitation < ApplicationRecord
  after_create_commit :create_invitation_message
  belongs_to :course
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  has_one :message, as: :messageable

  validate :recipient_not_yet_invited, on: :create
  validate :recipient_not_yet_instructor

  enum :response, %i[unread pending accepted], _default: :unread

  scope :with_includes, -> { includes(:course, sender: :profile) }
  scope :with_recipient, -> { includes(recipient: :profile) }
  scope :on_page, lambda { |page = 1|
    with_includes.not_accepted.order(created_at: :desc).limit(20).offset(20 * (page - 1))
  }

  def self.last_page?(page)
    count <= page * 20
  end

  def accepted!
    super
    promote_recipient_to_instructor
  end

  def as_json(options = {})
    super({ include: [:course, { sender: { methods: %i[avatar_url] } }] }.merge(options))
  end

  private

  def create_invitation_message
    create_message(
      sender:,
      recipient:,
      subject: "#{sender.username} has invited you to instruct a course!",
      body: 'Respond to Invitation'
    )
  end

  def promote_recipient_to_instructor
    add_unique(course.instructors, [recipient])
    course.enrollments.find_by(student: recipient)&.destroy
  end

  def recipient_not_yet_invited
    return unless !accepted? && recipient.received_instruction_invitations.not_accepted.exists?(course:)

    errors.add(:recipient, 'has already received an invitation')
  end

  def recipient_not_yet_instructor
    return unless !accepted? && recipient.instructed?(course)

    errors.add(:recipient, 'is already an instructor')
  end
end
