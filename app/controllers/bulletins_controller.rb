class BulletinsController < BaseController
  layout 'new_application'
  #before_filter :find_bulletin, :only => [:show, :edit, :update, :destroy]
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit])
  
  
  def index
		@bulletins = Bulletin.find(:all)
  end

  def show
    @bulletin = Bulletin.find(params[:id])
  end

  def new
    @bulletin = Bulletin.new()
  end

  def create
    @bulletin = Bulletin.new(params[:bulletin])
    @bulletin.school = School.find(params[:school_id])
    
    respond_to do |format|
      if @bulletin.save
        flash[:notice] = 'A notícia foi criada e adicionada à rede.'
        format.html { redirect_to(@bulletin) }
        format.xml  { render :xml => @bulletin, :status => :created, :location => @bulletin }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bulletin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @bulletin = Bulletin.find(params[:id])
  end
    
  end

  def update
    @bulletin = Bulletin.find(params[:id])
    
    respond_to do |format|
      if @bulletin.update_attributes(params[:bulletin])
        flash[:notice] = 'A notícia foi editada.'
        format.html { redirect_to (@bulletin)}
        formal.xml { render :xml => @bulletin, :status => :created, :location => @bulletin }
      else
        format.html { render :action => :edit }
        format.xml { render :xml => @bulletin.errors, :status => :unprocessable_entity }
      end
  end

  #TODO Colocar link para excluir notícia
  def destroy
    @bulletin = Bulletin.find(params[:id])
    
    @bulletin.destroy
    flash[:notice] = 'A notícia foi excluída.'
    redirect_to @bulletin.school.bulletins
  end
  
  #def find_bulletin
  #  @bulletin = Bulletin.find(params[:id])
  #end
  
end
