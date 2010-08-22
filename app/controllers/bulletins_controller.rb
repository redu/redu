class BulletinsController < BaseController
  layout 'new_application'
  #before_filter :find_bulletin, :only => [:show, :edit, :update, :destroy]
	before_filter :login_required
  
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

  #TODO Colocar link para excluir notícia
  def destroy
		puts params[:id]
    @bulletin = Bulletin.find(params[:id])
    puts @bulletin
    @bulletin.destroy
    flash[:notice] = 'A notícia foi excluída.'
    respond_to do |format|
      format.html { redirect_to(@bulletin.school) }
      format.xml  { head :ok }
    end
  end
  
  #def find_bulletin
  #  @bulletin = Bulletin.find(params[:id])
  #end
  
end
