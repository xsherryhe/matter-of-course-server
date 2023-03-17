class Profile < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :avatar, content_type: { in: ['image/jpeg', 'image/jpg', 'image/png', 'image/svg', 'image/gif'],
                                     message: 'is not an image (PNG, JPG, JPEG, SVG, or GIF)' }
  belongs_to :user
  has_one_attached :avatar

  def full_name
    [first_name, middle_name, last_name].select(&:present?).join(' ')
  end

  def default_avatar_url
    hash = Digest::MD5.hexdigest(user.email.strip.downcase)
    "https://www.gravatar.com/avatar/#{hash}?default=identicon"
  end
end
