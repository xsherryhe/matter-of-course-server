class Comment < ApplicationRecord
  validates :body, presence: true
  belongs_to :commentable, polymorphic: true
  belongs_to :creator, class_name: 'User'

  scope :with_includes, -> { includes(creator: :profile) }
  scope :on_page, ->(page = 1) { with_includes.order(created_at: :asc).limit(10).offset(10 * (page - 1)) }

  def self.last_page?(page)
    count <= page * 10
  end

  def course
    commentable.course
  end

  def creator_role
    return unless course

    { hosted?: 'host', instructed?: 'instructor', enrolled?: 'student' }.each do |method, role|
      return role if course.public_send(method, creator)
    end
  end

  def as_json(options)
    super({ methods: :creator_role, include: { creator: { methods: :name } } }.merge(options))
      .merge({ authorized: options[:authorized] || authorized_to_edit?(options[:user]) })
  end

  def authorized_to_edit?(user)
    creator == user && commentable.authorized_to_view?(user) && commentable.accepting_comments?
  end
end
