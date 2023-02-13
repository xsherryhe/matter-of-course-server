class Message < ApplicationRecord
  before_validation :set_recipient
  validates :subject, presence: true
  validates :body, presence: true
  validate :valid_recipient_login
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :parent, class_name: 'Message', optional: true
  has_many :replies, class_name: 'Message', foreign_key: 'parent_id'

  enum :read_status, %i[unread read deleted], _default: :unread

  scope :with_includes, -> { includes(sender: :profile, recipient: :profile) }
  scope :on_page, lambda { |page = 1|
    with_includes.limit(50).offset(50 * (page - 1))
  }
  scope :order_by_unread, -> { order(read_status: :asc, created_at: :desc) }
  scope :order_by_time, -> { order(created_at: :desc) }

  attr_accessor :recipient_login

  def as_json(options = {})
    super({ include: [{ recipient: { methods: :name }, sender: { methods: :name } }] }.merge(options))
  end

  def as_json_with_details(options = {})
    as_json(options).merge(options.key?(:role) ? { role: role_of(options[:role]) } : {})
  end

  def role_of(user)
    %w[sender recipient].find { |role| public_send(role) == user }
  end

  private

  def set_recipient
    return unless recipient_login

    self.recipient = User.find_by_login(recipient_login)
  end

  def valid_recipient_login
    return if recipient.present?

    errors.add(:recipient_login, recipient_login.present? ? 'is an invalid username or email' : "can't be blank")
  end
end
