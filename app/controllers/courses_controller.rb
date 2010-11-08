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

    respond_to do |format|
      if @course.save
        @environment.courses << @course
        format.html { redirect_to environment_course_path(@environment, @course) }
      else
        format.html { render :action => :new }
      end
    end

  end

  # Aba espaços.
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

  # Aba Moderação usuários.
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
                                               :role_id => Role[:student].id)

    if @course.subscription_type.eql? 1 # Todos podem participar, sem moderação
      association.approve!

      # Cria as associações no Environment do Course e em todos os seus Spaces.
      UserEnvironmentAssociation.create(:user_id => current_user.id, :environment_id => @course.environment.id, 
                                        :role_id => Role[:student].id)
      @course.spaces.each do |space|
        UserSpaceAssociation.create(:user_id => current_user.id, :space_id => space.id, 
                                    :role_id => Role[:student].id, :status => "approved") #FIXME tirar status quando remover moderacao de space
      end

      flash[:notice] = "Você agora faz parte do curso #{@course.name}"
    else
      flash[:notice] = "Seu pedido de participação foi feito. Aguarde a moderação."
    end

    redirect_to environment_course_path(@course.environment, @course)
  end


  # Desassocia um usuário de um Course (Ação de sair do Course).
  def unjoin
  end

end
