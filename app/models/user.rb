class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_.#!$*?]*\Z/ }
  validates :profile, presence: true

  has_one :profile, dependent: :destroy
  has_many :hosted_courses, class_name: 'Course', foreign_key: 'host_id', dependent: :restrict_with_error
  has_and_belongs_to_many :instructed_courses,
                          class_name: 'Course',
                          join_table: :instructed_courses_instructors,
                          foreign_key: 'instructor_id',
                          association_foreign_key: 'instructed_course_id'
  has_many :sent_instruction_invitations, class_name: 'InstructionInvitation', foreign_key: 'sender_id'
  has_many :received_instruction_invitations, class_name: 'InstructionInvitation', foreign_key: 'recipient_id'
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id'
  has_many :enrollments, foreign_key: 'student_id'
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :assignment_submissions, dependent: :destroy, foreign_key: 'student_id'
  has_many :posts, foreign_key: 'creator_id', dependent: :destroy
  has_many :comments, foreign_key: 'creator_id', dependent: :destroy
  accepts_nested_attributes_for :profile
  attr_writer :login

  def login
    @login || username || email
  end

  def self.find_by_login(login)
    where(['lower(username) = :value OR lower(email) = :value',
           { value: login.downcase }]).first
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    attributes = %i[username email]
    attributes.each { |attribute| conditions[attribute]&.downcase! }
    if (login = conditions.delete(:login))
      where(conditions.to_h).find_by_login(login)
    elsif attributes.any? { |attribute| conditions.key?(attribute) }
      find_by(conditions.to_h)
    end
  end

  def name
    profile.full_name
  end

  def all_courses(user, page, _)
    { hosted: hosted_courses, instructed: instructed_courses, enrolled: enrolled_courses }.transform_values do |courses|
      courses.authorized_for(user).on_page(page)
    end
  end

  def all_assignment_submissions(user, page, scope = {})
    return {} unless user == self

    assignment_submissions.by_course(scope[:course])
                          .on_page(page)
                          .group_by(&:completion_status)
  end

  def inbox_messages
    received_messages.not_deleted
  end

  def outbox_messages
    sent_messages.user_generated
  end

  def hosted?(course)
    course.hosted?(self)
  end

  def instructed?(course)
    course.instructed?(self)
  end

  def enrolled?(course)
    course.enrolled?(self)
  end

  def owned?(resource)
    resource.owned?(self)
  end

  def authorized_to_view?(resource)
    resource.authorized_to_view?(self)
  end

  def authorized_to_view_details?(resource)
    resource.authorized_to_view_details?(self)
  end

  def authorized_to_edit?(resource)
    resource.authorized_to_edit?(self)
  end

  def as_json(options = {})
    json = super({ methods: :name }.merge(options))
    %i[all_courses all_assignment_submissions].each { |key| json[key] = options[key] if options.key?(key) }
    json
  end
end
