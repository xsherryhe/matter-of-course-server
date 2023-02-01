class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_.#!$*?]*\Z/ }
  validates :first_name, presence: true
  validates :last_name, presence: true

  has_many :created_courses, class_name: 'Course', foreign_key: 'creator_id'
  has_and_belongs_to_many :instructed_courses,
                          class_name: 'Course',
                          join_table: :instructed_courses_instructors,
                          foreign_key: 'instructor_id',
                          association_foreign_key: 'instructed_course_id'
  attr_writer :login

  def login
    @login || username || email
  end

  def self.find_for_database_authentication
    conditions = warden_conditions.dup
    attributes = %i[username email]
    attributes.each { |attribute| conditions[attribute]&.downcase! }
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value',
                                    { value: login.downcase }]).first
    elsif attributes.any? { |attribute| conditions.key?(attribute) }
      find_by(conditions.to_h)
    end
  end
end
