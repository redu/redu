class BulletinsController < BaseController
  layout "environment"

  before_filter :find_environment_course_space
  before_filter :login_required
  before_filter :is_member_required
  before_filter :can_manage_required,
    :only => [:edit, :update, :destroy]
  after_filter :create_activity, :only => [:create]

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create, :update])

  def index
    @bulletinable = find_bulletinable

    @bulletins = Bulletin.paginate(:conditions => ["bulletinable_id = ?
                                   AND bulletinable_type LIKE ? 
                                   AND state LIKE 'approved'", 
                                   @bulletinable.id, @bulletinable.class.to_s],
                                   :page => params[:page],
                                   :order => 'created_at DESC',
                                   :per_page => 5)
  end

  def show
    @bulletin = Bulletin.find(params[:id])
    @owner = User.find(@bulletin.owner)
    @bulletinable = find_bulletinable
  end

  def new
    @bulletin = Bulletin.new
    @bulletinable = find_bulletinable
  end

  def create
    @bulletin = Bulletin.new(params[:bulletin])
    if params[:bulletinable_type].eql? "Space" or params[:bulletinable_type].eql? "Environment" 
      @bulletinable = Kernel.const_get(params[:bulletinable_type]).find(params[:bulletinable_id]) 
    end
    @bulletin.bulletinable = @bulletinable
    @bulletin.owner = current_user
    respond_to do |format|
      if @bulletin.save

        if @bulletin.owner.can_manage? @bulletin.bulletinable
          @bulletin.approve!
          flash[:notice] = 'A notícia foi criada e divulgada.'
        else
          flash[:notice] = 'A notícia foi criada e será divulgada assim que for aprovada pelo moderador.'
        end

        format.html { redirect_to polymorphic_path([@bulletin.bulletinable, @bulletin]) }
        format.xml  { render :xml => @bulletin, :status => :created, :location => @bulletin }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bulletin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @bulletin = Bulletin.find(params[:id])
    @bulletinable = find_bulletinable
  end

  def update
    @bulletin = Bulletin.find(params[:id])

    respond_to do |format|
      if @bulletin.update_attributes(params[:bulletin])
        flash[:notice] = 'A notícia foi editada.'
        format.html { redirect_to polymorphic_path([@bulletin.bulletinable, @bulletin])}
        format.xml { render :xml => @bulletin, :status => :created, :location => @bulletin, :bulletinable => @bulletin.bulletinable }
      else
        format.html { render :action => :edit }
        format.xml { render :xml => @bulletin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @bulletin = Bulletin.find(params[:id])
    @bulletin.destroy

    flash[:notice] = 'A notícia foi excluída.'
    respond_to do |format|
      format.html { redirect_to(@bulletin.bulletinable) }
      format.xml  { head :ok }
    end
  end

  def vote
    @bulletin = Bulletin.find(params[:id])
    # TODO ver porque o like quando setado para false vem nil

    if params[:like]
      current_user.vote_for(@bulletin)
    else
      current_user.vote_against(@bulletin)
    end

    respond_to do |format|
      # if falta o if para saber se é like ou dislike
      if params[:like]
        format.js { render :template => 'shared/like', :locals => {:votes_for => @bulletin.votes_for().to_s} }
      else
        format.js { render :template => 'shared/dislike', :locals => {:votes_against => @bulletin.votes_against().to_s} }
      end
    end
  end

  def rate
    @bulletin = Bulletin.find(params[:id])
    @bulletin.rate(params[:stars], current_user, params[:dimension])
    #FIXME Este trecho abaixo é usado pra quê?
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}bulletin-#{@bulletin.id}"

    respond_to do |format|
      format.js
    end      
  end

  protected

  def can_manage_required
    @bulletin = Bulletin.find(params[:id])

    current_user.can_manage?(@bulletin, @bulletin.bulletinable) ? true : access_denied
  end

  def is_member_required
    @bulletinable = find_bulletinable

    current_user.has_access_to(@bulletinable) ? true : access_denied
  end

  def find_bulletinable
    if params[:space_id]
      Space.find(params[:space_id])
    elsif params[:environment_id]
      Environment.find(params[:environment_id])
    else
      if params[:bulletinable_type].eql? "Space"
        Space.find(params[:bulletinable_id])
      end
    end
  end

  def find_environment_course_space
    if params[:space_id]
      @space = Space.find(params[:space_id])
      @course = @space.course
      @environment = @course.environment 
    elsif params[:environment_id]
      @environment = Environment.find(params[:environment_id])
    end
  end
end
