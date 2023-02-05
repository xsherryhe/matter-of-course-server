class InstructionInvitation < ApplicationRecord
  belongs_to :course
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validate :recipient_not_yet_invited
  validate :recipient_not_yet_authorized

  enum :response, %i[pending accepted], _default: :pending

  scope :on_page, ->(page = 1) { pending.order(created_at: :desc).limit(50).offset(50 * (page - 1)) }

  def accepted!
    super
    add_unique(course.instructors, [recipient])
  end

  private

  def recipient_not_yet_invited
    return unless pending? && recipient.received_instruction_invitations.pending.exists?(course:)

    errors.add(:recipient, 'has already received an invitation')
  end

  def recipient_not_yet_authorized
    return unless pending? && recipient.authorized_to_edit?(course)

    errors.add(:recipient, 'is already a host or instructor')
  end
end
