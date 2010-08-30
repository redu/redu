class BulletinsController < BaseController
  layout 'new_application'
  #before_filter :find_bulletin, :only => [:show, :edit, :update, :destroy]
	before_filter :login_required 
  before_filter :is_member_required
  before_filter :can_manage_required,
                :only => [:edit, :update, :destroy]
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit])
  
  
  def index
		@bulletins = Bulletin.paginate(:conditions => ["school_id = ? AND state LIKE 'approved'", School.find(params[:school_id]).id],
			:page => params[:page], 
		 	:order => 'created_at DESC', 
		 	:per_page => 5
		 )
		@school = School.find(params[:school_id])
  end

  def show
    @bulletin = Bulletin.find(params[:id])
    @owner = User.find(@bulletin.owner)
		@school = @bulletin.school
  end

  def new
    @bulletin = Bulletin.new()
		@school = School.find(params[:school_id])
  end

  def create
    @bulletin = Bulletin.new(params[:bulletin])
		@bulletin.school = School.find(params[:school_id])
    @bulletin.owner = current_user

    respond_to do |format|
      if @bulletin.save
        flash[:notice] = 'A notícia foi criada e adicionada à rede.'
        format.html { redirect_to school_bulletin_path(@bulletin.school, @bulletin) }
        format.xml  { render :xml => @bulletin, :status => :created, :location => @bulletin }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bulletin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @bulletin = Bulletin.find(params[:id])
		@school = School.find(params[:school_id])
	end

  def update
    @bulletin = Bulletin.find(params[:id])

    respond_to do |format|
      if @bulletin.update_attributes(params[:bulletin])
        flash[:notice] = 'A notícia foi editada.'
        format.html { redirect_to school_bulletin_path(@bulletin.school, @bulletin)}
        format.xml { render :xml => @bulletin, :status => :created, :location => @bulletin, :school => params[:school_id] }
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
      format.html { redirect_to(@bulletin.school) }
      format.xml  { head :ok }
    end
  end
  
  def vote
    @bulletin = Bulletin.find(params[:id])
		# TODO ver porque o like quando setado para false vem nil
		if params[:like] == nil
			current_user.vote(@bulletin, false) 
		else
    	current_user.vote(@bulletin, params[:like])
		end
    respond_to do |format|
		puts params[:like]
      format.js do 
        render :update do |page|
					# if falta o if para saber se é like ou dislike
					if params[:like]
		        page << "jQuery('#like_spinner').hide()"
		        page << "jQuery('#like_link').show()"
		        page << "jQuery('#like_link').attr('onclick', 'return false;')"
		        page << "jQuery('#like_count').html('" + @bulletin.votes_for().to_s + "')" # TODO performance + uma consulta?
					else 
						page << "jQuery('#dislike_spinner').hide()"
		        page << "jQuery('#dislike_link').show()"
		        page << "jQuery('#dislike_link').attr('onclick', 'return false;')"
		        page << "jQuery('#dislike_count').html('" + @bulletin.votes_against().to_s + "')" # TODO performance + uma consulta?
					end
        end
      end
    end
  end

	def rate
    @bulletin = Bulletin.find(params[:id])
    @bulletin.rate(params[:stars], current_user, params[:dimension])
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}bulletin-#{@bulletin.id}"
    
    render :update do |page|
     page.replace_html  @bulletin.wrapper_dom_id(params), ratings_for(@bulletin, params.merge(:wrap => false))

     # page.replace_html id, ratings_for(@course, :wrap => false, :dimension => params[:dimension])
     # page << "$('##{id}').effect('highlight', {}, 2000);" #TODO precisa do plugin de effects do jquery
      #page.visual_effect :highlight, id
    end
  end

protected

  def can_manage_required
     @bulletin = Bulletin.find(params[:id])
   
     current_user.can_manage?(@bulletin, @bulletin.school) ? true : access_denied
  end

  def is_member_required
		if params[:school_id]
			@school = School.find(params[:school_id])
		else
			@bulletin = Bulletin.find(params[:id])
			@school = @bulletin.school
		end
    
    current_user.has_access_to(@school) ? true : access_denied
  end
  
end
