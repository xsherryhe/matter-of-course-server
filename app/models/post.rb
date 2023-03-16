class Post < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  belongs_to :postable, polymorphic: true
  belongs_to :creator, class_name: 'User'
  has_many :comments, as: :commentable, dependent: :destroy

  scope :on_page, ->(page = 1) { order(created_at: :asc).limit(20).offset(20 * (page - 1)) }

  def self.last_page?(page)
    count <= page * 20
  end

  def as_json_with_details(options = {})
    as_json({ methods: :creator_role, include: { creator: { methods: %i[name avatar_url] } } }.merge(options))
      .merge(options.key?(:authorized) ? { authorized: options[:authorized] } : {})
  end

  def course
    postable.is_a?(Course) ? postable : postable.course
  end

  def creator_role
    { hosted?: 'host', instructed?: 'instructor', enrolled?: 'student' }.each do |method, role|
      return role if course.public_send(method, creator)
    end
  end

  def authorized_to_edit?(user)
    user == creator && authorized_to_view?(user)
  end

  def authorized_to_view?(user)
    postable.authorized_to_view_details?(user)
  end

  def accepting_comments?
    true
  end
end
