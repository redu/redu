require 'hpricot'
require 'open-uri'
require 'pp'

class BaseController < ApplicationController
  layout 'application'
  include AuthenticatedSystem
  include LocalizedApplication

  around_filter :set_locale

  skip_before_filter :verify_authenticity_token, :only => :footer_content
  # Work around (ver método self.login_required_base)
  before_filter :login_required_base, :only => [:teach_index, :learn_index, :site_index]

  caches_action :site_index, :footer_content, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && controller_name.eql?('base') && params[:format].blank?
  end

  def removed_item
    @type = params[:type]
  end

  def tos
    #TODO 
  end

  def privacy
    #TODO
  end

  def teach_index
    @spaces = current_user.spaces
    @lectures = current_user.lectures.find(:all,
                                         :order => "created_at DESC",
                                         :limit => 4,
                                         :conditions => ["published = ?", true])
    respond_to do |format|
      format.html 
    end
  end

  def learn_index
    @spaces = current_user.spaces

    respond_to do |format|
      format.html 
    end
  end

  def beta_index
    redirect_to home_path and return if logged_in?
    render :layout => false
  end

  def rss_site_index
    redirect_to :controller => 'base', :action => 'site_index', :format => 'rss'
  end

  def plaxo
    render :layout => false
  end

  def site_index
    redirect_to user_path(current_user) 
  end

  def footer_content
    get_recent_footer_content
    render :partial => 'shared/footer_content' and return
  end

  def homepage_features
    @homepage_features = HomepageFeature.find_features
    @homepage_features.shift
    render :partial => 'homepage_feature', :collection => @homepage_features and return
  end

  def advertise
    #TODO
  end

  def css_help
    #TODO
  end

  def admin_required
    current_user && current_user.admin? ? true : access_denied
  end

  def space_admin_required(space_id)
    (current_user && current_user.space_admin?(space_id) || Space.find(space_id).owner == current_user) ? true : access_denied
  end

  def admin_or_moderator_required
    current_user && (current_user.admin? || current_user.moderator?) ? true : access_denied
  end

  def create_activity
    return unless current_user.auto_status

    case params[:controller]
    when 'lectures'
      if @lecture and @lecture.published
        Status.create({:log => true,
                      :logeable_name => @lecture.name,
                      :logeable_type => 'Lecture',
                      :logeable_id => @lecture.id,
                      :log_action => params[:action],
                      :statusable_type => 'User',
                      :statusable_id => @lecture.owner.id,
                      :user_id => current_user.id
        })
      end
    when 'exams'
      if @exam and @exam.published
        Status.create({:log => true,
                      :logeable_name => @exam.name,
                      :logeable_type => 'Exam',
                      :logeable_id => @exam.id,
                      :log_action => params[:action],
                      :statusable_type => (@exam.space) ? 'Space' : 'User',
                      :statusable_id => (@exam.space) ? @exam.space.id : @exam.owner.id,
                      :user_id => current_user.id
        })
      end
    when 'users'
      if @user and params[:update_value]
        Status.create({:log => true,
                      :logeable_name => params[:update_value],
                      :logeable_type => 'User',
                      :logeable_id => @user.id,
                      :log_action => params[:action],
                      :statusable_type => 'User',
                      :statusable_id => @user.id,
                      :user_id => @user.id
        })
      end
    when 'spaces'
      if @space and @space.created_at
        Status.create({:log => true,
                      :logeable_name => @space.name,
                      :logeable_type => 'Space',
                      :logeable_id => @space.id,
                      :log_action => params[:action],
                      :statusable_type => 'User',
                      :statusable_id => @space.owner.id,
                      :user_id => current_user.id
        })
      end
    when 'topics'
      if @topic and @topic.created_at
        Status.create({:log => true,
                      :logeable_name => @topic.title,
                      :logeable_type => 'Topic',
                      :logeable_id => @topic.id,
                      :log_action => params[:action],
                      :statusable_type => 'Space',
                      :statusable_id => @topic.forum.space.id,
                      :user_id => current_user.id
        })
      end
    when 'sb_posts'
      if @post and @post.created_at
        Status.create({:log => true,
                      :logeable_name => nil,
                      :logeable_type => 'SbPost',
                      :logeable_id => @post.id,
                      :log_action => params[:action],
                      :statusable_type => 'Space',
                      :statusable_id => @post.topic.forum.space.id,
                      :user_id => current_user.id
        })
      end
    when 'events'
      if @event and @event.created_at
        Status.create({:log => true,
                      :logeable_name => @event.name,
                      :logeable_type => 'Event',
                      :logeable_id => @event.id,
                      :log_action => params[:action],
                      :statusable_type => @event.eventable.class.to_s,
                      :statusable_id => @event.eventable.id,
                      :user_id => current_user.id
        })
      end
    when 'bulletins'
      if @bulletin and @bulletin.created_at
        Status.create({:log => true,
                      :logeable_name => @bulletin.title,
                      :logeable_type => 'Bulletin',
                      :logeable_id => @bulletin.id,
                      :log_action => params[:action],
                      :statusable_type => @bulletin.bulletinable.class.to_s,
                      :statusable_id => @bulletin.bulletinable.id,
                      :user_id => current_user.id
        })
      end
    when 'folders'
      if @myfile.valid? and @space
        Status.create({:log => true,
                      :logeable_name => @myfile.attachment_file_name,
                      :logeable_type => 'Myfile',
                      :logeable_id => @myfile.id,
                      :log_action => params[:action],
                      :statusable_type => 'Space',
                      :statusable_id => @space.id,
                      :user_id => current_user.id
        })
      end
    end
  end

  def find_user
    # if @user = User.active.find(params[:user_id] || params[:id])
    if @user = User.find(params[:user_id] || params[:id])
      @is_current_user = (@user && @user.eql?(current_user))
      unless logged_in? || @user.profile_public?
        flash[:error] = :this_users_profile_is_not_public_youll_need_to_create_an_account_and_log_in_to_access_it.l
        redirect_to :controller => 'sessions', :action => 'new'
      end
      return @user
    else
      flash[:error] = :please_log_in.l
      redirect_to :controller => 'sessions', :action => 'new'
      return false
    end
  end

  def require_current_user
    @user ||= User.find(params[:user_id] || params[:id] )
    unless admin? || (@user && (@user.eql?(current_user)))
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end

  def popular_tags(limit = nil, order = ' tags.name ASC', type = nil)
    sql = "SELECT tags.id, tags.name, count(*) AS count
      FROM taggings, tags
      WHERE tags.id = taggings.tag_id "
      sql += " AND taggings.taggable_type = '#{type}'" unless type.nil?
      sql += " GROUP BY tags.id, tags.name"
      sql += " ORDER BY #{order}"
      sql += " LIMIT #{limit}" if limit
      Tag.find_by_sql(sql).sort{ |a,b| a.name.downcase <=> b.name.downcase}
  end

  def get_recent_footer_content
    #@recent_clippings = Clipping.find_recent(:limit => 10)
    @recent_photos = Photo.find_recent(:limit => 10)
    @recent_comments = Comment.find_recent(:limit => 13)
    @popular_tags = popular_tags(30, ' count DESC')
    @recent_activity = User.recent_activity(:size => 15, :current => 1)
  end

  def get_additional_homepage_data
    @sidebar_right = true
    @homepage_features = HomepageFeature.find_features
    @homepage_features_data = @homepage_features.collect {|f| [f.id, f.public_filename(:large) ]  }

    # @active_users = User.active.find_by_activity({:limit => 5, :require_avatar => false})
    @featured_writers = User.find_featured

    @featured_posts = Post.find_featured

    @topics = Topic.find(:all, :limit => 5, :order => "replied_at DESC")

    @active_contest = Contest.get_active
    @popular_posts = Post.find_popular({:limit => 10})
    @popular_polls = Poll.find_popular(:limit => 8)
  end


  def commentable_url(comment)
    if comment.recipient && comment.commentable
      if comment.commentable_type != "User"
        polymorphic_url([comment.recipient, comment.commentable])+"#comment_#{comment.id}"
      elsif comment
        user_url(comment.recipient)+"#comment_#{comment.id}"
      end
    elsif comment.commentable
      polymorphic_url(comment.commentable)+"#comment_#{comment.id}"
    end
  end

  def commentable_comments_url(commentable)
    if commentable.owner && commentable.owner != commentable
      "#{polymorphic_path([commentable.owner, commentable])}#comments"
    else
      "#{polymorphic_path(commentable)}#comments"
    end
  end

  def contact
    if request.get?
      @contact = Contact.new
    else
      @contact = Contact.new
      @contact.name = params[:contact][:name]
      @contact.email = params[:contact][:email]
      @contact.kind = params[:contact][:kind]
      @contact.subject = params[:contact][:subject]
      @contact.body = params[:contact][:body]
      if @contact.valid?
        @contact.deliver
        flash[:notice] = "Seu e-mail foi enviado, aguarde o nosso contato. Obrigado."
        redirect_to contact_path
      else
        render :action => :contact, :method => :get
      end
    end
  end

  protected
  # Workaround para o bug #55 (before_filter não funciona no filter chain)
  # http://railsapi.com/doc/rails-v2.3.8/classes/ActionController/Filters/ClassMethods.html
  def login_required_base
    login_required
  end
end
