class Forum < ActiveRecord::Base

  belongs_to :space
  has_many :moderatorships, :dependent => :destroy
  has_many :moderators, :through => :moderatorships, :source => :user

  has_many :topics, :order => 'locked desc, replied_at desc', :dependent => :destroy do
    def first
      @first_topic ||= find(:first)
    end
  end

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, :class_name => 'Topic', :order => 'replied_at desc' do
    def first
      @first_recent_topic ||= find(:first)
    end
  end

  has_many :sb_posts, :order => 'sb_posts.created_at desc' do
    def last
      @last_post ||= find(:first, :include => :user)
    end
  end

  belongs_to :owner, :polymorphic => true

  acts_as_taggable

  validates_presence_of :name

  def to_param
    id.to_s << "-" << (name ? name.parameterize : '' )
  end

end
