class TopicsController < BaseController
  layout "environment"
  load_and_authorize_resource :space
  load_and_authorize_resource :topic, :except => [:new, :create], :through => :space

  before_filter :find_environmnet_course
  after_filter :create_activity, :only => [:create]

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create, :update])

  def new
    authorize! :read, @space
    @topic = Topic.new(params[:topic])
    @topic.body = params[:topic][:body] if params[:topic] 
  end
  
  def show
    respond_to do |format|
      format.html do
        # see notes in base_controller.rb on how this works
        current_user.update_last_seen_at if logged_in?
        # keep track of when we last viewed this topic for activity indicators
        (session[:topics] ||= {})[@topic.id] = Time.now.utc if logged_in?
        # authors of topics don't get counted towards total hits
        @topic.hit! unless logged_in? and @topic.user == current_user

        @posts = @topic.sb_posts.recent.paginate(:page => params[:page], 
                                                 :include => :user,
                                                 :order => 'created_at',
                                                 :per_page => AppConfig.items_per_page)

        @voices = @posts.map(&:user)
        @voices.uniq!
        @post   = SbPost.new
      end
      format.js do
        @posts = @topic.sb_posts.recent.paginate(:page => params[:page], 
                                                 :include => :user,
                                                 :order => 'created_at',
                                                 :per_page => AppConfig.items_per_page)

      end
      format.xml do
        render :xml => @topic.to_xml
      end
      format.rss do
        @posts = @topic.sb_posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :action => 'show.xml.builder', :layout => false
      end
    end
  end
  
  def create
    authorize! :read, @space
    # this is icky - move the topic/first post workings into the topic model?
    Topic.transaction do
      @topic = @forum.topics.build(params[:topic])
      assign_protected
      @post = @topic.sb_posts.build(params[:topic])
      @post.topic = @topic
      @post.user = current_user
      # only save topic if post is valid so in the view topic will be a new record if there was an error
      @topic.tag_list = params[:topic][:tag_list] || ''
      @topic.space = @space
      if @post.valid?
        @topic.save 
      else
        flash[:notice] = "Você precisa escrever algo para ser a primeira postagem."
      end
      @post.save
    end
    if not @post.valid? or not @topic.valid?
      respond_to do |format|
        format.html { 
          render :action => 'new' and return
        }
      end
    else
      respond_to do |format|
        format.html { 
          redirect_to space_forum_topic_path(@space, @topic) 
        }
        format.xml  { 
          head :created, :location => forum_topic_url(:forum_id => @forum, :id => @topic, :format => :xml) 
        }
      end
    end
  end
  
  def update
    assign_protected
    
    respond_to do |format|
     if @topic.update_attributes(params[:topic])
        flash[:notice] = 'O post foi editado.'
        format.html { redirect_to space_forum_topic_path(@space, @topic) }
        format.xml { render :xml => @topic, :status => :created, :location => @topic, :space => params[:space_id] }
        format.js 
     else
        format.html { render :action => :edit }
        format.xml { render :xml => @topic.errors, :status => :unprocessable_entity }
        format.js
     end
   end
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = :topic_deleted.l_with_args(:topic => CGI::escapeHTML(@topic.title)) 
    respond_to do |format|
      format.html { redirect_to space_path(@space) }
      format.xml  { head 200 }
    end
  end
  
  protected
    def assign_protected
      @topic.user     = current_user if @topic.new_record?
      # admins and moderators can sticky and lock topics
      return unless admin? or current_user.moderator_of?(@topic.forum)
      @topic.locked = params[:topic][:locked] 
      # only admins can move
      return unless admin?
      @topic.forum_id = params[:topic][:forum_id] if params[:topic][:forum_id]
    end
    
    def find_environmnet_course
      @forum = @space.forum
      @course = @space.course
      @environment = @course.environment
    end
end
