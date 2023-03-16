class Message < ApplicationRecord
  before_validation :set_recipient
  validates :subject, presence: true
  validates :body, presence: true
  validate :valid_recipient_login
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :parent, class_name: 'Message', optional: true
  belongs_to :messageable, polymorphic: true, optional: true
  has_many :replies, class_name: 'Message', foreign_key: 'parent_id'

  enum :read_status, %i[unread read deleted], _default: :unread

  scope :with_includes, -> { includes(sender: :profile, recipient: :profile) }
  scope :on_page, lambda { |page = 1|
    with_includes.order(created_at: :desc).limit(30).offset(30 * (page - 1))
  }
  scope :user_generated, -> { where(messageable: nil) }

  attr_accessor :recipient_login

  def self.last_page?(page)
    count <= page * 30
  end

  def as_json(options = {})
    super({ include: [{ recipient: { methods: %i[name avatar_url] }, sender: { methods: %i[name avatar_url] } }] }.merge(options))
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
