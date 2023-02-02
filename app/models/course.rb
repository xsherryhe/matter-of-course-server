class Course < ApplicationRecord
  before_validation :add_creator_as_instructor, only: %i[create]
  before_validation :set_instructors
  validates :title, presence: true
  validates :description, presence: true
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :instructors,
                          class_name: 'User',
                          join_table: :instructed_courses_instructors,
                          foreign_key: 'instructed_course_id',
                          association_foreign_key: 'instructor_id'
  enum :status, %i[pending open closed], _default: :pending

  scope :on_page, lambda { |page = 1|
    all.includes([{ creator: :profile }, { instructors: :profile }])
       .order(title: :asc).limit(50).offset(50 * (page - 1))
  }

  attr_accessor :instructor_logins

  def as_json(options)
    super({ include: [creator: { methods: :name }, instructors: { methods: :name }] }.merge(options))
  end

  private

  def add_creator_as_instructor
    add_unique(instructors, [creator])
  end

  def set_instructors
    return unless instructor_logins

    new_instructors = instructor_logins.split(/, */).filter_map do |login|
      user = User.where(['lower(username) = :value OR lower(email) = :value',
                         { value: login.downcase }]).first
      return errors.add(:instructor_logins, 'have invalid usernames or emails') unless user

      user
    end
    add_unique(instructors, new_instructors)
  end
end
