class InteractiveClassesController < BaseController
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit])
  

  def index
    @iclasses = InteractiveClass.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @iclasses }
    end
  end

  def show
    @iclass = InteractiveClass.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @iclass }
    end
  end

  # GET /abilities/new
  # GET /abilities/new.xml
  def new
    @iclass = InteractiveClass.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @iclass }
    end
  end

  # GET /abilities/1/edit
  def edit
    @iclass = InteractiveClass.find(params[:id])
  end

  # POST /abilities
  # POST /abilities.xml
  def create
    @iclass = InteractiveClass.new(params[:iclass])

    respond_to do |format|
      if @iclass.save
        flash[:notice] = 'InteractiveClass was successfully created.'
        format.html { redirect_to(@iclass) }
        format.xml  { render :xml => @iclass, :status => :created, :location => @iclass }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @iclass.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /abilities/1
  # PUT /abilities/1.xml
  def update
    @iclass = InteractiveClass.find(params[:id])

    respond_to do |format|
      if @iclass.update_attributes(params[:ability])
        flash[:notice] = 'InteractiveClass was successfully updated.'
        format.html { redirect_to(@iclass) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @iclass.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /abilities/1
  # DELETE /abilities/1.xml
  def destroy
    @iclass = InteractiveClass.find(params[:id])
    @iclass.destroy

    respond_to do |format|
      format.html { redirect_to(abilities_url) }
      format.xml  { head :ok }
    end
  end
end
