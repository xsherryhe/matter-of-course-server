class Video < ApplicationRecord
  validates :src, attached: true,
                  content_type: { in: 'video/mp4',
                                  message: 'is not an accepted video format (MP4)' }
  validates :thumbnail, content_type: { in: ['image/jpeg', 'image/jpg', 'image/png', 'image/svg', 'image/gif'],
                                        message: 'is not an image (PNG, JPG, JPEG, SVG, or GIF)' }
  has_one_attached :src
  has_one_attached :thumbnail
  belongs_to :videoable, polymorphic: true

  include Rails.application.routes.url_helpers

  def thumbnail_url
    thumbnail.attached? ? url_for(thumbnail) : "#{root_url}/default-video-thumbnail.svg"
  end

  def src_url
    url_for(src)
  end
end
