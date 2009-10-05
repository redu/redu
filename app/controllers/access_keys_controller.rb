class AccessKeysController < BaseController
  #before_filter :login_required
  #before_filter :admin_required, :only => [:new, :create, :edit, :update, :destroy, :index]

  
  
 ### Admin (Redu) actions
 
 def grant_keys_to_school
   n = params[:number].to_i
   for k in 0...n do
      ak = AccessKey.create(:expiration_date => (params[:exp_date] ? params[:exp_date] : Time.now))
      UserSchoolAssociation.create(:school_id => params[:id].to_i, :access_key => ak)
  end
  
  #redirecionar
end

 
 def renew_keys(keys)
   
 end
 

  # GET /access_keys
  # GET /access_keys.xml
  def index
      @user_school_associations = UserSchoolAssociation.find(:all)
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_school_associations }
    end
  end
  
  def index_school
    school = params[:id]
    if school
      @user_school_associations = UserSchoolAssociation.find(:all, :conditions => ['school_id = ?', school])
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_school_associations }
    end
  end
  
  

  # GET /access_keys/1
  # GET /access_keys/1.xml
  def show
    @access_key = AccessKey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @access_key }
    end
  end


  # GET /access_keys/1/edit
  def edit
    @access_key = AccessKey.find(params[:id])
  end

  # POST /access_keys
  # POST /access_keys.xml
  def create
    @access_key = AccessKey.new(params[:access_key])

    respond_to do |format|
      if @access_key.save
        flash[:notice] = 'AccessKey was successfully created.'
        format.html { redirect_to(@access_key) }
        format.xml  { render :xml => @access_key, :status => :created, :location => @access_key }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @access_key.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /access_keys/1
  # PUT /access_keys/1.xml
  def update
    @access_key = AccessKey.find(params[:id])

    respond_to do |format|
      if @access_key.update_attributes(params[:access_key])
        flash[:notice] = 'AccessKey was successfully updated.'
        format.html { redirect_to(@access_key) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @access_key.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /access_keys/1
  # DELETE /access_keys/1.xml
  def destroy
    @access_key = AccessKey.find(params[:id])
    @access_key.destroy

    respond_to do |format|
      format.html { redirect_to(access_keys_url) }
      format.xml  { head :ok }
    end
  end
  
 
  
end
