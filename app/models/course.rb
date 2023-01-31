class Course < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :instructors,
                          class_name: 'User',
                          join_table: :instructed_courses_instructors,
                          foreign_key: 'instructed_course_id',
                          association_foreign_key: 'instructor_id'
  enum :status, %i[pending open closed]

  scope :on_page, ->(page = 1) { all.order(title: :asc).limit(50).offset(50 * (page - 1)) }
end
