class Course < ApplicationRecord
  before_validation :add_host_as_instructor, on: %i[create]
  before_validation :build_and_check_instructor_invitations
  validates :title, presence: true
  validates :description, presence: true
  validates :instructors, presence: true
  validate :valid_instructor_logins
  validate :open_with_lessons
  belongs_to :host, class_name: 'User'
  has_and_belongs_to_many :instructors,
                          class_name: 'User',
                          join_table: :instructed_courses_instructors,
                          foreign_key: 'instructed_course_id',
                          association_foreign_key: 'instructor_id'
  has_many :instruction_invitations
  has_many :lessons, dependent: :destroy
  enum :status, %i[pending open closed], _default: :pending

  scope :with_includes, -> { includes([{ host: :profile }, { instructors: :profile }]) }
  scope :on_page, lambda { |page = 1|
    open.with_includes.order(title: :asc).limit(50).offset(50 * (page - 1))
  }
  scope :authorized_for, lambda { |user|
    return where(status: :open) unless user

    table = joins(:instructors)
    table.where(status: :open)
         .or(table.where(host: user))
         .or(table.where("instructed_courses_instructors.instructor_id": user.id))
         .distinct
         .with_includes
  }

  attr_accessor :editor, :instructor_logins, :instructor_logins_by_validity

  def as_json(options = {})
    super({ include: [{ host: { methods: :name } }, { instructors: { methods: :name } }] }.merge(options))
  end

  def as_json_with_details(options = {})
    authorized = options[:authorized]
    as_json({
      include: [{ host: { methods: :name } }, { instructors: { methods: :name } }, :lessons]
    }.merge(options))
      .merge(authorized ? instruction_invitations_as_json : {})
      .merge(options.key?(:authorized) ? { authorized: } : {})
      .merge(options.key?(:hosted) ? { hosted: options[:hosted] } : {})
  end

  def authorized_for?(user)
    open? || authorized_to_edit?(user)
  end

  def authorized_to_edit?(user)
    user&.authorized_to_edit?(self)
  end

  def single_instructor?
    instructors.size == 1
  end

  def simplified_errors
    super.merge(instructor_logins: instructor_logins_by_validity)
  end

  private

  def instruction_invitations_as_json
    { instruction_invitations: instruction_invitations.pending.as_json(include: :recipient) }
  end

  def add_host_as_instructor
    add_unique(instructors, [host])
  end

  def build_and_check_instructor_invitations
    self.instructor_logins_by_validity = { valid: [], invalid: {} }
    return unless instructor_logins

    instructor_logins.split(/, */).uniq.each do |login|
      user = User.find_by_login(login)
      next instructor_logins_by_validity[:invalid][login] = 'is an invalid username or email' unless user

      build_and_check_instructor_invitation(user, login)
    end
  end

  def build_and_check_instructor_invitation(user, login)
    invitation = instruction_invitations.build(sender: editor, recipient: user)
    if invitation.valid?
      instructor_logins_by_validity[:valid] << login
    else
      instructor_logins_by_validity[:invalid][login] = invitation.errors[:recipient].first
    end
  end

  def valid_instructor_logins
    errors.add(:instructor_logins, 'are invalid') unless instructor_logins_by_validity[:invalid].empty?
  end

  def open_with_lessons
    return unless open? && !lessons.exists?

    errors.add(:base, 'You must have at least one lesson to open the course.')
  end
end
