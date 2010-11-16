class CoursesController < BaseController
  layout "environment"

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :create, :update])

  def show
    @environment = Environment.find(params[:environment_id])
    @course = Course.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def edit
    @environment = Environment.find(params[:environment_id])
    @course = Course.find(params[:id])
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    @environment = Environment.find(params[:environment_id])

    respond_to do |format|
      flash[:notice] = "Curso removido."
      format.html { redirect_to(environment_path(@environment)) }
      format.xml  { head :ok }
    end
  end

  def update
    @course = Course.find(params[:id])
    @environment = Environment.find(params[:environment_id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        if params[:course][:subscription_type].eql? "1" # Entrada de membros passou a ser livre, aprovar todos os membros pendentes
          UserCourseAssociation.update_all("state = 'approved'", ["course_id = ? AND state = 'waiting'", @course.id])
        end

        flash[:notice] = 'O curso foi editado.'
        format.html { redirect_to(environment_course_path(@environment, @course)) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new
    @course_being_created = Course.new
    @environment = Environment.find(params[:environment_id])
  end

  def create
    #TODO verificar permissoes
    @environment = Environment.find(params[:environment_id])
    @course = Course.new(params[:course])
    @course.owner = current_user

    respond_to do |format|
      if @course.save
        @environment.courses << @course
        owner_assoc = UserCourseAssociation.create({:user => current_user, :course => @course, 
                                                   :role_id => Role[:environment_admin].id})
        owner_assoc.approve!
        format.html { redirect_to environment_course_path(@environment, @course) }
      else
        format.html { render :action => :new }
      end
    end

  end

  # Visão do Course para usuários não-membros. 
  # TODO Remover quando colocar as permissões, apenas redirecionar no show.
  def preview
    @course = Course.find(params[:id])
    @environment = @course.environment

  end

  # Aba Espaços.
  def admin_spaces
    @course = Course.find(params[:id])
    @environment = @course.environment
    @spaces = Space.paginate(:conditions => ["course_id = ?", @course.id],
                             :include => :owner,
                             :page => params[:page],
                             :order => 'updated_at ASC',
                             :per_page => 20)

    respond_to do |format|
      format.html
    end
  end

  # Aba Moderação de Membros.
  def admin_members_requests
    @course = Course.find(params[:id])
    @environment = @course.environment
    @pending_members = UserCourseAssociation.paginate(:conditions => ["state LIKE 'waiting' AND course_id = ?", @course.id],
                                                      :page => params[:page],
                                                      :order => 'updated_at DESC',
                                                      :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html
    end

  end

  # Modera os usuários.
  def moderate_members_requests
    @course = Course.find(params[:id])
    @environment = @course.environment

    if params[:member].nil? 
      flash[:notice] = "Escolha, pelo menos, algum usuário."
    else
      approved = params[:member].reject{|k,v| v == 'reject'}
      rejected = params[:member].reject{|k,v| v == 'approve'}

      approved.keys.each do |user_id|
        UserCourseAssociation.update_all("state = 'approved'", :user_id => user_id,  :course_id => @course.id)
      end

      rejected.keys.each do |user_id|
        UserCourseAssociation.update_all("state = 'rejected'", :user_id => user_id,  :course_id => @course.id)
      end

      @approved_members = User.all(:conditions => ["id IN (?)", approved.keys]) unless approved.empty?
      @rejected_members = User.all(:conditions => ["id IN (?)", rejected.keys]) unless rejected.empty?

      # Cria as associações no Environment do Course e em todos os seus Spaces.
      if @approved_members
        @approved_members.each do |member|
          UserEnvironmentAssociation.create(:user_id => member.id, :environment_id => @course.environment.id, 
                                            :role_id => Role[:student].id)
          @course.spaces.each do |space|
            UserSpaceAssociation.create(:user_id => member.id, :space_id => space.id, 
                                        :role_id => Role[:student].id, :status => "approved") #FIXME tirar status quando remover moderacao de space
          end

          UserNotifier.deliver_approve_membership(member, @course) # TODO fazer isso em batch
        end
      end

      if @rejected_members
        @rejected_members.each do |member|
          UserNotifier.deliver_reject_membership(member, @course) #TODO fazer isso em batch
        end
      end

      flash[:notice] = 'Membros moderados!'
    end

    redirect_to admin_members_requests_environment_course_path(@environment, @course)
  end

  # Associa um usuário a um Course (Ação de participar).
  def join
    @environment = Environment.find(params[:environment_id])
    @course = Course.find(params[:id])

    association = UserCourseAssociation.create(:user_id => current_user.id, :course_id => @course.id, 
                                               :role_id => Role[:member].id)

    if @course.subscription_type.eql? 1 # Todos podem participar, sem moderação
      association.approve!

      # Cria as associações no Environment do Course e em todos os seus Spaces.
      UserEnvironmentAssociation.create(:user_id => current_user.id, :environment_id => @course.environment.id, 
                                        :role_id => Role[:member].id)
      @course.spaces.each do |space|
        UserSpaceAssociation.create(:user_id => current_user.id, :space_id => space.id, 
                                    :role_id => Role[:member].id, :status => "approved") #FIXME tirar status quando remover moderacao de space
      end

      flash[:notice] = "Você agora faz parte do curso #{@course.name}"
    else
      flash[:notice] = "Seu pedido de participação foi feito. Aguarde a moderação."
    end

    redirect_to environment_course_path(@course.environment, @course)
  end


  # Desassocia um usuário de um Course (Ação de sair do Course).
  def unjoin
    @course = Course.find(params[:id])

    course_association = current_user.get_association_with(@course)    
    course_association.destroy
    @course.spaces.each do |space|
      space_association = current_user.get_association_with(space)    
      space_association.destroy
    end

    flash[:notice] = "Você não participa mais do curso #{@course.name}"
    redirect_to environment_course_path(@course.environment, @course)
  end

  def publish
    @course = Course.find(params[:id])   
    @environment = @course.environment

    @course.published = 1
    @course.save

    flash[:notice] = "O curso #{@course.name} foi publicado."
    redirect_to environment_course_path(@environment, @course)
  end

  def unpublish
    @course = Course.find(params[:id])   
    @environment = @course.environment

    @course.published = 0
    @course.save

    flash[:notice] = "O curso #{@course.name} foi despublicado."
    redirect_to environment_course_path(@environment, @course)
  end
  
  # Aba Membros. 
  def admin_members
    @course= Course.find(params[:id])
    @environment = @course.environment
    @memberships = UserCourseAssociation.paginate(
      :conditions => ["course_id = ? AND state LIKE ? ", @course.id, 'approved'],
      :include => [{ :user => {:user_space_associations => :space} }],
      :page => params[:page],
      :order => 'updated_at DESC',
      :per_page => AppConfig.items_per_page)
  end

  # Remove um ou mais usuários de um Environment destruindo todos os relacionamentos
  # entre usuário e os níveis mais baixos da hierarquia.
  def destroy_members
    @course = Course.find(params[:id])

    # Course.id do environment
    spaces = @course.spaces
    users_ids = []
    users_ids = params[:users].collect{|u| u.to_i} if params[:users]

    unless users_ids.empty?
      User.find(:all,
                :conditions => {:id => users_ids},
                :include => [:user_course_associations,
                  :user_space_associations]).each do |user|

        user.spaces.delete(spaces)
        user.courses.delete(@course)
                  end
      flash[:notice] = "Os usuários foram removidos do curso #{@course.name}"
    end

    respond_to do |format|
      format.html { redirect_to :action => :admin_members }
    end
  end

  def search_users_admin
    @course = Course.find(params[:id])
    @environment = @course.environment

    roles = []
    roles = params[:role_filter].collect {|r| r.to_i} if params[:role_filter]
    keyword = []
    keyword = params[:search_user] || nil

    @memberships = UserCourseAssociation.with_roles(roles)
    @memberships = @memberships.with_keyword(keyword).paginate(
      :conditions => ["user_course_associations.course_id = ?", @course.id],
      :include => [{ :user => {:user_space_associations => :space} }],
      :page => params[:page],
      :order => 'user_course_associations.updated_at DESC',
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
