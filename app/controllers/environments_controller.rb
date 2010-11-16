class EnvironmentsController < BaseController
  layout "environment"

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create, :update])

  # GET /environments
  # GET /environments.xml
  def index
    @environments = Environment.all

    respond_to do |format|
      format.html { render :layout => "application" }
      format.xml  { render :xml => @environments }
    end
  end

  # GET /environments/1
  # GET /environments/1.xml
  def show
    @environment = Environment.find(params[:id])
    @courses = @environment.courses

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @environment }
    end
  end

  # GET /environments/new
  # GET /environments/new.xml
  def new
    @environment = Environment.new

    respond_to do |format|
      format.html { render :layout => 'application' }
      format.xml  { render :xml => @environment }
    end
  end

  # GET /environments/1/edit
  def edit
    @environment = Environment.find(params[:id])
  end

  # POST /environments
  # POST /environments.xml
  def create
    @environment = Environment.new(params[:environment])
    @environment.owner = current_user
    @environment.courses.first.owner = current_user
    @environment.published = true

    respond_to do |format|
      if @environment.save
        UserEnvironmentAssociation.create(:environment => @environment,
                                          :user => current_user,
                                          :role_id => Role[:environment_admin].id)
        user_course = UserCourseAssociation.create(
          :course => @environment.courses.first,
          :user => current_user,
          :role_id => Role[:environment_admin].id)

        user_course.approve!

        flash[:notice] = 'Environment was successfully created.'
        format.html do
          redirect_to environment_course_path(@environment,
                                              @environment.courses.first)
        end
        format.xml  { render :xml => @environment, :status => :created, :location => @environment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @environment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /environments/1
  # PUT /environments/1.xml
  def update
    @environment = Environment.find(params[:id])

    respond_to do |format|
      if @environment.update_attributes(params[:environment])
        flash[:notice] = 'Environment was successfully updated.'
        format.html { redirect_to(@environment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @environment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /environments/1
  # DELETE /environments/1.xml
  def destroy
    @environment = Environment.find(params[:id])
    @environment.destroy

    respond_to do |format|
      format.html { redirect_to(environments_url) }
      format.xml  { head :ok }
    end
  end
  
  # Visão do Environment para usuários não-membros. 
  # TODO Remover quando colocar as permissões, apenas redirecionar no show.
  def preview
    @environment = Environment.find(params[:id])
  end

  def admin_courses
    @environment = Environment.find(params[:id])
    @courses = @environment.courses
  end

  def admin_members
    @environment = Environment.find(params[:id])
    @memberships = UserEnvironmentAssociation.paginate(
      :conditions => ["environment_id = ?", @environment.id],
      :include => [{ :user => {:user_course_associations => :course} }],
      :page => params[:page],
      :order => 'updated_at DESC',
      :per_page => AppConfig.items_per_page)
  end

  # Remove um ou mais usuários de um Environment destruindo todos os relacionamentos
  # entre usuário e os níveis mais baixos da hierarquia.
  def destroy_members
    @environment = Environment.find(params[:id], :include => {:courses => :spaces})

    # Course.id do environment
    courses = @environment.courses
    # Spaces do environment (unidimensional)
    spaces = courses.collect{ |c| c.spaces }.flatten
    users_ids = []
    users_ids = params[:users].collect{|u| u.to_i} if params[:users]

    unless users_ids.empty?
      User.find(:all,
                :conditions => {:id => users_ids},
                :include => [:user_environment_associations,
                             :user_course_associations,
                             :user_space_associations]).each do |user|

        user.spaces.delete(spaces)
        user.courses.delete(courses)
        user.environments.delete(@environment)
      end
      flash[:notice] = "Os usuários foram removidos do ambiente #{@environment.name}"
    end

    respond_to do |format|
      format.html { redirect_to :action => :admin_members }
    end
  end

  def search_users_admin
    @environment = Environment.find(params[:id])

    roles = []
    roles = params[:role_filter].collect {|r| r.to_i} if params[:role_filter]
    keyword = []
    keyword = params[:search_user] || nil

    @memberships = UserEnvironmentAssociation.with_roles(roles)
    @memberships = @memberships.with_keyword(keyword).paginate(
      :conditions => ["user_environment_associations.environment_id = ?", @environment.id],
      :include => [{ :user => {:user_course_associations => :course} }],
      :page => params[:page],
      :order => 'user_environment_associations.updated_at DESC',
      :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'user_list', :partial => 'user_list_admin', :locals => {:memberships => @memberships}
        end
      end
    end
  end
end
