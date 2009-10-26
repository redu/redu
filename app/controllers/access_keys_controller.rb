class AccessKeysController < BaseController
  #before_filter :login_required
  #before_filter :admin_required, :only => [:new, :create, :edit, :update, :destroy, :index]

  
  
 ### Admin (Redu) actions
 
 def grant_keys_to_school
   n = params[:number].to_i
   
   date = Date.new(params[:exp_date][:year].to_i, params[:exp_date][:month].to_i, params[:exp_date][:day].to_i)
   
   for k in 0...n do
      ak = AccessKey.create(:expiration_date => date)
      UserSchoolAssociation.create(:school_id => params[:school_id].to_i, :access_key => ak)
   end
  
 #render :text => "OK" 
 #render :nothing
 redirect_to :action => :index_school , :id => params[:school_id]
 
 
end

 
 def manage_keys
   
   @ids = params[:ids]
   
   
   
   
   if @ids # se alguma chave foi selecionada
   
      case params[:option]
        when '1' #Renovar prazo
           date = Date.new(params[:exp_date][:year].to_i, params[:exp_date][:month].to_i, params[:exp_date][:day].to_i)
           #AccessKey.update_all 'expiration_date = ' + date, 'id = Associations.access_key AND Associations.id IN (' + params[:ids]* "," + ')'

# AccessKey.update_all 'expiration_date = "2009-12-29 15:31:38"', 'id = user_school_associations.access_key AND user_school_associations.id IN (1,2,3,4,5,6,7,8,9,10)'
#AccessKey.update_all 'expiration_date = "2009-12-29 15:31:38"', 'id = Associations.access_key AND Associations.id IN (1,2,3,4,5,6,7,8,9,10)'
AccessKey.find(:all, :include => :user_school_association,  :conditions => ["user_school_associations.id IN (?)", params[:ids]]).update_all('expiration_date = "2009-12-29 15:31:38"')
#puts @aks
=begin          
         
          
          #@association.find(:all).each { |customer| customer.update_attribute :zip, '60623' }
          
          UserSchoolAssociation.update_all 'zip = 60620', 'zip IS NULL'
          
          @ids.each do |association_id|
            @association = UserSchoolAssociation.find(association_id)
          end

=end          
        when '2' #Renovar chave
      when '3' #Mudar papel
        UserSchoolAssociation.update_all 'role_id = ' + params[:role_id], 'id IN (' + params[:ids]* "," + ')'
      end
    end
    
     redirect_to :action => :index_school, :id => params[:id]
   
 end
  
  def sort_keys
    
    order = (params[:order] == 1) ? "DESC" : "ASC"
    @school = School.find(params[:id])
    
    case params[:sort_by]
      when '1' #Data de expiração
      @user_school_associations = UserSchoolAssociation.find(:all, :include => :access_key, :conditions => ['school_id = ?', @school.id], :order => "access_keys.expiration_date " + order)
      
      when '2' #Nome de aluno
      @user_school_associations = UserSchoolAssociation.find(:all, :include => :user, :conditions => ['school_id = ?', @school.id], :order => "users.login " + order)
      
      when '3' #Papel
      @user_school_associations = UserSchoolAssociation.find(:all, :conditions => ['school_id = ?', @school.id], :order => "role_id " + order)
      
    end
    
    render :action => :index_school
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
    @school = School.find(params[:id])
    if @school
      @user_school_associations = UserSchoolAssociation.find(:all, :include => :access_key, :conditions => ['school_id = ?', @school.id], :order => "access_keys.expiration_date DESC")
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
