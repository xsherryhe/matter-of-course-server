class Course < ApplicationRecord
  before_validation :add_host_as_instructor, on: %i[create]
  before_validation :build_and_check_instructor_invitations
  validates :title, presence: true
  validates :description, presence: true
  validates :instructors, presence: true
  validates :avatar, content_type: { in: ['image/jpeg', 'image/jpg', 'image/png', 'image/svg', 'image/gif'],
                                     message: 'is not an image (PNG, JPG, JPEG, SVG, or GIF)' }
  validate :valid_instructor_logins
  validate :logical_lessons_order
  validate :open_with_lessons
  belongs_to :host, class_name: 'User'
  has_and_belongs_to_many :instructors,
                          class_name: 'User',
                          join_table: :instructed_courses_instructors,
                          foreign_key: 'instructed_course_id',
                          association_foreign_key: 'instructor_id'
  has_many :instruction_invitations, dependent: :destroy
  has_many :lessons, dependent: :destroy
  has_many :assignments, through: :lessons
  has_many :assignment_submissions, through: :assignments
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments
  has_many :posts, as: :postable, dependent: :destroy
  has_one_attached :avatar
  accepts_nested_attributes_for :lessons, allow_destroy: true

  enum :status, %i[pending open closed], _default: :pending

  scope :with_includes, -> { includes([{ host: :profile }, { instructors: :profile }]) }
  scope :on_page, lambda { |page = 1|
    with_includes.order(title: :asc).limit(30).offset(30 * (page - 1))
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
  scope :single_instructor, lambda { 
    joins(:instructors)
    .group(:id)
    .having('count(instructed_courses_instructors.instructor_id) = 1') 
  }

  include Rails.application.routes.url_helpers

  attr_accessor :editor, :instructor_logins, :instructor_logins_by_validity

  def self.last_page?(page = 1)
    count <= page * 30
  end

  def as_json(options = {})
    super({ include: [{ host: { methods: %i[name avatar_url] } }, 
                      { instructors: { methods: %i[name avatar_url] } }],
            methods: %i[avatar_url] }
          .merge(options))
  end

  def as_json_with_details(options = {})
    authorized = options[:authorized]
    as_json({
      include: [{ host: { methods: %i[name avatar_url] } }, { instructors: { methods: %i[name avatar_url] } }]
    }.merge(options))
      .merge({ lessons: lessons_as_json })
      .merge(authorized ? instruction_invitations_as_json : {})
      .merge(options.key?(:authorized) ? { authorized: } : {})
      .merge(options.key?(:hosted) ? { hosted: options[:hosted] } : {})
      .merge(options.key?(:enrolled) ? { enrolled: options[:enrolled] } : {})
  end

  def hosted?(user)
    host == user
  end

  def instructed?(user)
    user && instructors.exists?(user.id)
  end

  def enrolled?(user)
    user && students.exists?(user.id)
  end

  def authorized_to_view?(user)
    open? || authorized_to_edit?(user)
  end

  def authorized_to_view_details?(user)
    (open? && enrolled?(user)) || authorized_to_edit?(user)
  end

  def authorized_to_edit?(user)
    hosted?(user) || instructed?(user)
  end

  def single_instructor?
    instructors.size == 1
  end

  def avatar_url
    avatar.attached? ? url_for(avatar) : "#{root_url}/default-course-avatar.svg"
  end

  def simplified_errors
    super.merge(instructor_logins: instructor_logins_by_validity)
  end

  private

  def lessons_as_json
    lessons.order(order: :asc).as_json
  end

  def instruction_invitations_as_json
    { instruction_invitations: instruction_invitations
        .not_accepted
        .with_recipient
        .as_json(include: { recipient: { methods: :avatar_url } }) }
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

  def logical_lessons_order
    remaining_lessons = lessons.reject(&:marked_for_destruction?)
    return if remaining_lessons.sort_by(&:order).map(&:order) == (1..remaining_lessons.size).to_a

    errors.add(:lessons, 'do not follow logical numbering order')
  end

  def open_with_lessons
    return unless open? && !lessons.exists?

    errors.add(:base, 'You must have at least one lesson to open the course.')
  end
end
