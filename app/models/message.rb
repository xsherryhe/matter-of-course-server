class Message < ApplicationRecord
  before_validation :set_recipient
  validates :subject, presence: true
  validates :body, presence: true
  validate :valid_recipient_login
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :parent, class_name: 'Message', optional: true
  has_many :replies, class_name: 'Message', foreign_key: 'parent_id'

  enum :read_status, %i[unread read], _default: :unread

  scope :with_includes, -> { includes(sender: :profile, recipient: :profile) }
  scope :head, -> { where(parent: nil) }
  scope :on_page, lambda { |page = 1|
    head.with_includes.order(created_at: :desc).limit(50).offset(50 * (page - 1))
  }

  attr_accessor :recipient_login

  def as_json(options = {})
    super({ include: [{ recipient: { methods: :name }, sender: { methods: :name } }] }.merge(options))
  end

  private

  def set_recipient
    self.recipient = User.find_by_login(recipient_login)
  end

  def valid_recipient_login
    return if recipient.present?

    errors.add(:recipient_login, recipient_login.present? ? 'is an invalid username or email' : "can't be blank")
  end
end
