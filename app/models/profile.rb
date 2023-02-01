class Profile < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  belongs_to :user

  def full_name
    [first_name, middle_name, last_name].join(' ')
  end
end
