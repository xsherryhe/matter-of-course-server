class Lesson < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  belongs_to :course
end
