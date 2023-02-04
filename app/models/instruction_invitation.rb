class InstructionInvitation < ApplicationRecord
  belongs_to :course
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validate :recipient_not_yet_authorized

  enum :response, %i[pending accepted], _default: :pending

  private

  def recipient_not_yet_authorized
    return unless pending? && recipient.authorized_to_edit?(course)

    errors.add(:recipient, 'is already a host or instructor')
  end
end
