class ResourcesController < BaseController
  
  def add
    @resources = Resource.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resources }
    end
  end
  
  def sort
    
  end

  def search
    
    @resources = Resource.find(:all, :conditions => ["title LIKE ?", "%" + params[:query] + "%"])
    #, :conditions => ["statement LIKE '%?%'", params[:query]]
    
    respond_to do |format|
      format.js do
          render :update do |page| 
            page.replace_html 'local_search_results', :partial => 'resources/item', :collection => @resources, :as => :resource
           # :partial => "questions/list_item", :collection => @products, :as => :item 
            #page.insert_html :bottom, "questions", :partial => 'questions/question_show', :object => @question
            #page.visual_effect :highlight, "question_#{@question.id}" 
          end
      end
    end
  end
  
  
  
  
  def rate
    @resource = Resource.find(params[:id])
    @resource.rate(params[:stars], current_user, params[:dimension])
     id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}recourse-#{@resource.id}"
    
    render :update do |page|
      page.replace_html id, ratings_for(@resource, :wrap => false, :dimension => params[:dimension])
      page.visual_effect :highlight, id
    end
  end
  
=begin desnecessario pois tem um controller central de comentarios que faz isso 
  def put_comment
    
    if current_user
   
    thecomment = params[:comment]
    @commentable = Resource.find(params[:id])
    @commentable.comments.create(:comment => thecomment, :user => current_user)
    
    else
      flash[:error] = 'Usuário não logado'
    end
      redirect_to :back
    
  end
=end
  
  # GET /resources
  # GET /resources.xml
  def index
    
    if params[:user_id]
      #@resources = Resource.all(:conditions => ["owner = ?", params[:user_id]])
      @user = User.find(params[:user_id])
      @resources = @user.resources
       respond_to do |format|
        format.html { render :action => "my" }
        format.xml  { render :xml => @resources }
      end
    else
      #@resources = Resource.all(:conditions => "state = 'converted'")
      @resources = Resource.all.reject {|resource|  (resource.video? and not resource.state.eql?("converted")) }
        respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @resources }
      end
    end
    
  end

  # GET /resources/1
  # GET /resources/1.xml
  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.xml
  def new
    @resource = Resource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
  end

  # POST /resources
  # POST /resources.xml
  def create
  
    # there is a better place?
  	if params[:resource][:external_resource_type] == "media" then
  		params[:resource][:external_resource] = nil
  	else
  		params[:resource][:media] = nil
  	end
  	
    @resource = Resource.new(params[:resource])
    @resource.owner = current_user
    
    respond_to do |format|
      if @resource.audio?
        puts "entrou linha 130"
          @resource.state = "converted"
      else
           puts "nao entrou linha 130"
      end  
      
      if @resource.save!
      	if @resource.video?
      		@resource.convert
      	end
				flash[:notice] = 'Resource was successfully created.'
		    format.html { redirect_to(@resource) }
		    format.xml  { render :xml => @resource, :status => :created, :location => @resource }
      end
			"""
      if @resource.save!
        if @resource.video?
          @resource.convert
        end
        flash[:notice] = 'Resource was successfully created.'
        format.html { redirect_to(@resource) }
        format.xml  { render :xml => @resource, :status => :created, :location => @resource }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end """
    end
  end

  # PUT /resources/1
  # PUT /resources/1.xml
  def update
    @resource = Resource.find(params[:id])

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        flash[:notice] = 'Resource was successfully updated.'
        format.html { redirect_to(@resource) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.xml
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to(resources_url) }
      format.xml  { head :ok }
    end
  end
end
