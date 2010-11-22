class ForumsController < BaseController
  load_and_authorize_resource :space
  load_and_authorize_resource :forum, :through => :space

  helper :application

  uses_tiny_mce do
    AppConfig.default_mce_options
  end

  def index
    @forums = Forum.find(:all, :order => "position")
    respond_to do |format|
      format.html
      format.xml { render :xml => @forums.to_xml }
    end
  end

  def show
    @forum = @space.forum
    respond_to do |format|
      # keep track of when we last viewed this forum for activity indicators
      (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?

      @topics = @forum.topics.paginate(:page => params[:page], 
                                       :include => :replied_by_user, 
                                       :order => 'locked DESC, replied_at DESC',
                                       :per_page => 20)
      format.html do
        redirect_to space_path(@space)
      end
      format.xml do
        render :xml => @forum.to_xml
      end
      format.js
    end
  end

  # new renders new.rhtml

  def create
    @forum.attributes = params[:forum]
    @forum.tag_list = params[:tag_list] || ''
    @forum.save!
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head :created, :location => forum_url(:id => @forum, :format => :xml) }
    end
  end

  def update
    @forum.attributes = params[:forum]
    @forum.tag_list = params[:tag_list] || ''
    @forum.save!
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head 200 }
    end
  end

  def destroy
    @forum.destroy
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head 200 }
    end
  end
end
