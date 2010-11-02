class BulletinsController < BaseController
  before_filter :login_required
  before_filter :is_member_required
  before_filter :can_manage_required,
    :only => [:edit, :update, :destroy]

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create, :update])

  def index
    @bulletins = Bulletin.paginate(:conditions => ["space_id = ? AND state LIKE 'approved'", Space.find(params[:space_id]).id],
                                   :page => params[:page],
                                   :order => 'created_at DESC',
                                   :per_page => 5
                                  )
    @space = Space.find(params[:space_id])
  end

  def show
    @bulletin = Bulletin.find(params[:id])
    @owner = User.find(@bulletin.owner)
    @space = @bulletin.space
  end

  def new
    @bulletin = Bulletin.new()
    @space = Space.find(params[:space_id])
  end

  def create
    @bulletin = Bulletin.new(params[:bulletin])
    @bulletin.space = Space.find(params[:space_id])
    @bulletin.owner = current_user

    respond_to do |format|
      if @bulletin.save

        if @bulletin.owner.can_manage? @bulletin.space
          @bulletin.approve!
          flash[:notice] = 'A notícia foi criada e divulgada.'
        else
          flash[:notice] = 'A notícia foi criada e será divulgada assim que for aprovada pelo moderador.'
        end

        format.html { redirect_to space_bulletin_path(@bulletin.space, @bulletin) }
        format.xml  { render :xml => @bulletin, :status => :created, :location => @bulletin }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bulletin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @bulletin = Bulletin.find(params[:id])
    @space = Space.find(params[:space_id])
  end

  def update
    @bulletin = Bulletin.find(params[:id])

    respond_to do |format|
      if @bulletin.update_attributes(params[:bulletin])
        flash[:notice] = 'A notícia foi editada.'
        format.html { redirect_to space_bulletin_path(@bulletin.space, @bulletin)}
        format.xml { render :xml => @bulletin, :status => :created, :location => @bulletin, :space => params[:space_id] }
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
      format.html { redirect_to(@bulletin.space) }
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
    # Este trecho abaixo é usado pra quê?
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}bulletin-#{@bulletin.id}"

    respond_to do |format|
      format.js
    end      
  end

  protected

  def can_manage_required
    @bulletin = Bulletin.find(params[:id])

    current_user.can_manage?(@bulletin, @bulletin.space) ? true : access_denied
  end

  def is_member_required
    if params[:space_id]
      @space = Space.find(params[:space_id])
    else
      @bulletin = Bulletin.find(params[:id])
      @space = @bulletin.space
    end

    current_user.has_access_to(@space) ? true : access_denied
  end
end
