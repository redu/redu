class LessonsController < BaseController
  
 # uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit])
  

 

  def show
    @lesson = Lesson.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lesson }
    end
  end

  # GET /abilities/new
  # GET /abilities/new.xml
  def new
    @lesson = Lesson.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lesson }
    end
  end

  # GET /abilities/1/edit
  def edit
    @lesson = Lesson.find(params[:id])
  end

  # POST /abilities
  # POST /abilities.xml
  def create
    @lesson = Lesson.new(params[:lesson])

    respond_to do |format|
      if @lesson.save
        flash[:notice] = 'Lesson was successfully created.'
        format.html { redirect_to(@lesson) }
        format.xml  { render :xml => @lesson, :status => :created, :location => @lesson }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lesson.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /abilities/1
  # PUT /abilities/1.xml
  def update
    @lesson = Lesson.find(params[:id])

    respond_to do |format|
      if @lesson.update_attributes(params[:ability])
        flash[:notice] = 'Lesson was successfully updated.'
        format.html { redirect_to(@lesson) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lesson.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /abilities/1
  # DELETE /abilities/1.xml
  def destroy
    @lesson = Lesson.find(params[:id])
    @lesson.destroy

    respond_to do |format|
      format.html { redirect_to(abilities_url) }
      format.xml  { head :ok }
    end
  end
end
