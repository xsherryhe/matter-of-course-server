class Course < ApplicationRecord
  before_validation :add_host_as_instructor, only: %i[create]
  before_validation :set_instructors
  validates :title, presence: true
  validates :description, presence: true
  validate :open_with_lessons
  belongs_to :host, class_name: 'User'
  has_and_belongs_to_many :instructors,
                          class_name: 'User',
                          join_table: :instructed_courses_instructors,
                          foreign_key: 'instructed_course_id',
                          association_foreign_key: 'instructor_id'
  has_many :lessons, dependent: :destroy
  enum :status, %i[pending open closed], _default: :pending

  scope :with_includes, -> { includes([{ host: :profile }, { instructors: :profile }]) }
  scope :on_page, lambda { |page = 1|
    all.with_includes.where(status: :open).order(title: :asc).limit(50).offset(50 * (page - 1))
  }
  scope :authorized_for, lambda { |user|
    return where(status: :open) unless user

    table = joins(:instructors)
    table.where(status: :open)
         .or(table.where(host: user))
         .or(table.where("instructed_courses_instructors.instructor_id": user.id))
         .with_includes
  }

  attr_accessor :instructor_logins

  def as_json(options = {})
    super({ include: [{ host: { methods: :name } }, { instructors: { methods: :name } }] }.merge(options))
  end

  def as_json_with_details(options = {})
    as_json({ include: [{ host: { methods: :name } }, { instructors: { methods: :name } }, :lessons] }.merge(options))
      .merge(options.key?(:authorized) ? { authorized: options[:authorized] } : {})
  end

  def authorized_for?(user)
    open? || authorized_to_edit?(user)
  end

  def authorized_to_edit?(user)
    user&.authorized_to_edit?(self)
  end

  private

  def add_host_as_instructor
    add_unique(instructors, [host])
  end

  def set_instructors
    return unless instructor_logins

    new_instructors = instructor_logins.split(/, */).map do |login|
      user = User.where(['lower(username) = :value OR lower(email) = :value',
                         { value: login.downcase }]).first
      return errors.add(:instructor_logins, 'have invalid usernames or emails') unless user

      user
    end
    add_unique(instructors, new_instructors)
  end

  def open_with_lessons
    return unless open? && !lessons.exists?

    errors.add(:base, 'You must have at least one lesson to open the course.')
  end
end
