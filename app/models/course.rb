class Course < ApplicationRecord
  before_validation :add_creator_as_instructor, only: %i[create]
  before_validation :set_instructors
  validates :title, presence: true
  validates :description, presence: true
  validate :open_with_lessons
  belongs_to :creator, class_name: 'User', optional: true
  has_and_belongs_to_many :instructors,
                          class_name: 'User',
                          join_table: :instructed_courses_instructors,
                          foreign_key: 'instructed_course_id',
                          association_foreign_key: 'instructor_id'
  has_many :lessons, dependent: :destroy
  enum :status, %i[pending open closed], _default: :pending

  scope :with_includes, -> { includes([{ creator: :profile }, { instructors: :profile }]) }
  scope :on_page, lambda { |page = 1|
    all.with_includes.where(status: :open).order(title: :asc).limit(50).offset(50 * (page - 1))
  }
  scope :authorized_for, lambda { |user|
    return where(status: :open) unless user

    table = joins(:instructors)
    table.where(status: :open)
         .or(table.where(creator: user))
         .or(table.where("instructed_courses_instructors.instructor_id": user.id))
         .with_includes
  }

  attr_accessor :instructor_logins

  def as_json(options = {})
    super({ include: [creator: { methods: :name }, instructors: { methods: :name }] }.merge(options))
      .merge(options.key?(:authorized) ? { authorized: options[:authorized] } : {})
  end

  def authorized_for?(user)
    open? || authorized_to_edit?(user)
  end

  def authorized_to_edit?(user)
    user&.authorized_to_edit?(course)
  end

  private

  def add_creator_as_instructor
    add_unique(instructors, [creator])
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
    return unless course.open? && !course.lessons.exists?

    errors.add(:base, 'You must have at least one lesson to open the course.')
  end
end
