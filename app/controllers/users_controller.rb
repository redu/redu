class UsersController < BaseController

  after_filter :create_activity, :only => [:update]
  load_and_authorize_resource :except => [:forgot_password,
    :forgot_username, :resend_activation, :activate]

  def annotations
    @annotations = User.find(params[:id]).annotations

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html  'tabs-5-content', :partial => 'annotations'
        end
      end
    end
  end

  def learning
    paginating_params = {
      :page => params[:page],
      :order => (params[:sort]) ? params[:sort] + ' DESC' : 'created_at DESC',
      :per_page => 6
    }

    if params[:search] # search
      @courses = @user.courses.name_like_all(params[:search].to_s.split).ascend_by_name
      @courses = @courses.published if cannot? :manage, @user
      @courses = @courses.paginate(paginating_params)
    else
      @courses = @user.courses
      @courses = @courses.published if cannot? :manage, @user
      @courses = @courses.paginate(paginating_params)
    end

    respond_to do |format|
      if params[:page]
        format.js { render :template => "courses/index" }
      else
      format.js
      end
    end
  end

  def teaching
    @lectures = @user.lectures[0..5] # TODO limitar pela query (limit = 5)
    @exams = @user.exams[0..5]

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html  'tabs-3-content', :partial => 'teaching'
        end
      end
    end
  end

  def show_log_activity
    current_user.log_activity
  end

  def list_subjects
    @subjects = Subject.all
    @user = params[:id]
  end

  def logs
    #TODO
  end

  ## User
  def activate
    redirect_to signup_path and return if params[:id].blank?
    @user = User.find_by_activation_code(params[:id])
    if @user and @user.activate
      self.current_user = @user
      redirect_to user_path(@user)
      flash[:notice] = :thanks_for_activating_your_account.l
      return
    end
    flash[:error] = :account_activation_error.l_with_args(:email => AppConfig.support_email)
    redirect_to signup_path
  end

  def deactivate
    @user.deactivate
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = :deactivate_completed.l
    redirect_to login_path
  end

  def index
    cond, @search, @metro_areas, @states = User.paginated_users_conditions_with_search(params)
    @users = User.recent.find(:all,
                              :conditions => cond.to_sql,
                              :include => [:tags],
                              :page => {:current => params[:page], :size => 20}
                             )

                             @tags = User.tag_counts :limit => 10

                             setup_metro_areas_for_cloud
  end

  def show
    if @user.removed
      redirect_to removed_page_path and return
    end

    @statuses = @user.profile_activity(params[:page])
    @statusable = @user
    @status = Status.new

    respond_to do |format|
      format.html do
        render :template => 'users/new/show', :layout => 'new/application'
      end
      format.js do
        render :template => 'users/new/show'
      end
    end
  end

  def new
    @user         = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    @inviter_id   = params[:id]
    @inviter_code = params[:code]

    @beta_key = params[:beta_key]

    respond_to do |format|
      format.html do
        render :template => 'users/new/new', :layout => 'new/clean'
      end
    end
  end

  def create
    @user = User.new(params[:user])

    if AppConfig.closed_beta_mode
      if params[:beta_key]
        @key = BetaKey.find(:first, :conditions => ["beta_keys.key like ?", params[:beta_key]])
        if @key
          if @key.user
            flash[:error] = "Esta chave de acesso já está sendo usada por outro usuário."
            render :action => 'new' and return
          end
        else
          flash[:error] = "Chave de acesso inválida!"
          render :action => 'new' and return
        end
      else
        flash[:error] = "Chave de acesso inválida!"
        render :action => 'new' and return
      end
    end

    @user.save do |result| # LINE A
      if result
        if @key
          @key.user = @user
          @key.save
        end

        # Se tem um token de convite para o curso, aprova o convite para o
        # usuário recém-cadastrado
        if params.has_key?(:invitation_token)
          invite = UserCourseInvitation.find_by_token(params[:invitation_token])
          invite.user = @user
          invite.accept!
        end

        flash[:notice] = :email_signup_thanks.l_with_args(:email => @user.email)
        redirect_to signup_completed_user_path(@user)
      else
        # Se tem um token de convite para o curso, atribui as variáveis
        # necessárias para mostrar o convite em Users#new
        if params.has_key?(:invitation_token)
          @user_course_invitation = UserCourseInvitation.find_by_token(
            params[:invitation_token])
          @course = @user_course_invitation.course
          @environment = @course.environment
        end

        unless @user.oauth_token.nil?
          @user = User.find_by_oauth_token(@user.oauth_token)
          unless @user.nil?
            @user_session = UserSession.create(@user)
            current_user = @user_session.record
            flash[:notice] = :thanks_youre_now_logged_in.l
            redirect_back_or_default user_path(current_user)
          else
            flash[:notice] = :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again.l
            render :action => :new
          end
        else
          if AppConfig.closed_beta_mode
            @beta_key  = @key.key
          end
          render :template => 'users/new/new', :layout => 'new/clean'
        end
      end
    end
  end

  def edit
    @metro_areas, @states = setup_locations_for(@user)
    respond_to do |format|
      format.html do
        render :template => 'users/new/edit', :layout => 'new/application'
      end
    end
  end

  def update
    case params[:element_id]
    when 'user-description'
      params[:user] = {:description => params[:update_value]}
    end

    # Substituindo ids por Privacies
    params[:user][:settings_attributes].each_key do |setting|
      if setting != 'id'
        params[:user][:settings_attributes][setting] = Privacy.find(
          params[:user][:settings_attributes][setting])
      end
    end

    @user.attributes      = params[:user]
    @metro_areas, @states = setup_locations_for(@user)

    unless params[:metro_area_id].blank?
      @user.metro_area  = MetroArea.find(params[:metro_area_id])
      @user.state       = (@user.metro_area && @user.metro_area.state) ? @user.metro_area.state : nil
      @user.country     = @user.metro_area.country if (@user.metro_area && @user.metro_area.country)
    else
      @user.metro_area = @user.state = @user.country = nil
    end

    @user.tag_list = params[:tag_list] || ''

    debugger
    #alteracao de senha na conta do usuario
    if params.has_key? "current_password" and !params[:current_password].empty?

      @flag = false
      authenticated = UserSession.new(:login => @user.login, :password => params[:current_password]).save

      unless authenticated
        @current_password = params[:current_password]
        @user.errors.add_to_base("A senha atual está incorreta")
        @flag = true
      end

    end

    if @user.errors.empty? && @user.save
      respond_to do |format|
        format.html do
          flash[:notice] = :your_changes_were_saved.l
          unless params[:welcome]

            redirect_to(user_path(@user))
          else
            redirect_to(:action => "welcome_#{params[:welcome]}", :id => @user)
          end
        end
        format.js do
          render :update do |page|
            page.replace_html '#user-description', params[:update_value]
          end
        end
      end
    else
    if (@user.errors.on(:password) or @user.errors.on(:email) or
       !params[:current_password].nil?)
        render 'users/new/account', :layout => 'new/application'
      else
        render 'users/new/edit', :layout => 'new/application'
      end
    end
  rescue ActiveRecord::RecordInvalid
      render 'users/new/edit', :layout => 'new/application'
  end

  def destroy
    if current_user == @user
      @user.destroy
      flash[:notice] = :the_user_was_deleted.l
      redirect_to :controller => 'sessions', :action => 'new' and return
    elsif @user.admin? #|| @user.featured_writer?
      @user.destroy
      flash[:notice] = :the_user_was_deleted.l
    elsif current_user.admin?
      @user.destroy
      flash[:notice] = :the_user_was_deleted.l
      redirect_to :controller => 'admin', :action => 'users' and return
    else
      flash[:error] = :you_cant_delete_that_user.l
    end
    respond_to do |format|
      format.html { redirect_to admin_moderate_users_path }
    end
  end

  def change_profile_photo
    #@user   = User.find(params[:id])
    @photo  = Photo.find(params[:photo_id])
    @user.avatar = @photo

    if @user.save!
      flash[:notice] = :your_changes_were_saved.l
      redirect_to user_photo_path(@user, @photo)
    end
  rescue ActiveRecord::RecordInvalid
    @metro_areas, @states = setup_locations_for(@user)
    render :action => 'edit'
  end

  def crop_profile_photo
    unless @photo = @user.avatar
      flash[:notice] = :no_profile_photo.l
      redirect_to upload_profile_photo_user_path(@user) and return
    end
    return unless request.put?

    if @photo
      if params[:x1]
        img = Magick::Image::read(@photo.path_or_s3_url_for_image).first.crop(params[:x1].to_i, params[:y1].to_i,params[:width].to_i, params[:height].to_i, true)
        img.format = @photo.content_type.split('/').last
        crop = {'tempfile' => StringIO.new(img.to_blob), 'content_type' => @photo.content_type, 'filename' => "custom_#{@photo.filename}"}
        @photo.uploaded_data = crop
        @photo.save!
      end
    end

    redirect_to user_path(@user)
  end

  def upload_profile_photo
    @avatar       = Photo.new(params[:avatar])
    return unless request.put?

    @avatar.user  = @user
    if @avatar.save
      @user.avatar  = @avatar
      @user.save
      redirect_to crop_profile_photo_user_path(@user)
    end
  end

  def edit_account
    @user             = current_user
    @is_current_user  = true
  end

  def update_account
    @user             = current_user
    @user.attributes  = params[:user]

    if @user.save
      flash[:notice] = :your_changes_were_saved.l
      respond_to do |format|
        format.html {redirect_to user_path(@user)}
        format.js
      end
    else
      respond_to do |format|
        format.html {render :action => 'edit_account'}
        format.js
      end
    end
  end

  def edit_pro_details
  end

  def update_pro_details
    @user.add_offerings(params[:offerings]) if params[:offerings]
    @user.attributes = params[:user]

    if @user.save!
      respond_to do |format|
        format.html {
          flash[:notice] = :your_changes_were_saved.l
          redirect_to edit_pro_details_user_path(@user)
        }
        format.js {
          render :text => 'success'
        }
      end

    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit_pro_details'
  end

  def signup_completed
    redirect_to home_path and return unless @user
    render :template => "users/new/signup_completed", :layout => "new/clean"
  end

  def invite
  end

  def welcome_complete
    flash[:notice] = :walkthrough_complete.l_with_args(:site => AppConfig.community_name)
    redirect_to user_path
  end

  def forgot_password
    return unless request.post?
    @user = User.find_by_email(params[:email])

    if @user && @user.reset_password
      UserNotifier.deliver_reset_password(@user)
      @user.save

      # O usuario estava ficando logado, apos o comando @user.save.
      # Destruindo sessao caso ela exista.
      if UserSession.find
        UserSession.find.destroy
      end

      redirect_to home_path
      flash[:info] = :your_password_has_been_reset_and_emailed_to_you.l
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end
  end

  def forgot_username
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      UserNotifier.deliver_forgot_username(@user)
      redirect_to home_path
      flash[:info] = :your_username_was_emailed_to_you.l
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end
  end

  def resend_activation
    return unless request.post?
    if params[:email]
      @user = User.find_by_email(params[:email])
    else
      @user = User.find(params[:id])
    end
    if @user
      flash[:notice] = :activation_email_resent_message.l
      UserNotifier.deliver_signup_notification(@user)
      redirect_to login_path and return
    else
      flash[:notice] = :activation_email_not_sent_message.l
    end
  end

  def assume
    self.current_user = User.find(params[:id])
    redirect_to user_path(current_user)
  end

  def metro_area_update
    country = Country.find(params[:country_id]) unless params[:country_id].blank?
    state   = State.find(params[:state_id]) unless params[:state_id].blank?
    states  = country ? country.states.sort_by{|s| s.name} : []

    if states.any?
      metro_areas = state ? state.metro_areas.all(:order => "name") : []
    else
      metro_areas = country ? country.metro_areas : []
    end

    respond_to do |format|
      format.js {
        render :partial => 'shared/location_chooser', :locals => {
        :states => states,
        :metro_areas => metro_areas,
        :selected_country => params[:country_id].to_i,
        :selected_state => params[:state_id].to_i,
        :selected_metro_area => nil }
      }
    end
  end

  def statistics
    if params[:date]
      date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
      @month = Time.parse(date.to_s)
    else
      @month = Date.today
    end

    start_date  = @month.beginning_of_month
    end_date    = @month.end_of_month + 1.day

    @posts = @user.posts.find(:all,
                              :conditions => ['? <= published_at AND published_at <= ?', start_date, end_date])

    @estimated_payment = @posts.sum do |p|
      7
    end
  end

  def activity_xml
    # talvez seja necessario setar o atributo depth nos nós para que funcione corretamente.
    # ver: http://asterisq.com/products/constellation/roamer/integration#data_rest_tree

    @user = User.find((params[:node_id]) ?  params[:node_id] :  params[:id] )
    @activities = Status.activities(@user)
    respond_to do |format|
      format.xml
    end
  end

  # Faz download do currículo previamente guardado pelo usuário.
  def download_curriculum
    if Rails.env == "production" || Rails.env == "staging"
      redirect_to @user.curriculum.expiring_url(20) and return false
    end

    send_file @user.curriculum.path,
      :type => @user.curriculum.content_type
  end

  def home
    @friends = current_user.friends.paginate(:page => 1, :per_page => 9)
    @friends_requisitions = current_user.friends_pending
    @course_invitations = current_user.course_invitations
    @statuses = current_user.home_activity(params[:page])
    @status = Status.new

    respond_to do |format|
      format.html do
        render :template => 'users/new/home', :layout => 'new/application'
      end
      format.js do
        render :template => 'users/new/home'
      end
    end
  end

  def mural
    @friends = current_user.friends.paginate(:page => 1, :per_page => 9)
    @statuses = current_user.statuses.not_response.
      paginate(:page => params[:page], :per_page => 10)
    @status = Status.new

    respond_to do |format|
      format.html do
        render :template => 'users/new/mural', :layout => 'new/application'
      end
      format.js do
        render :template => 'users/new/mural'
      end
    end
  end

  def account
    respond_to do |format|
      format.html do
        render :template => 'users/new/account', :layout => 'new/application'
      end
    end

  end

  # Dada uma palavra-chave retorna json com usuários que possuem aquela palavra.
  def auto_complete
    if params[:q]
      @users = User.with_keyword(params[:q])
      @users = @users.map do |u|
        { :id => u.id, :name => u.display_name, :avatar_32 => u.avatar.url(:thumb_32) }
      end
    end

    respond_to do |format|
      format.js do
        render :json => @users
      end
    end
  end


  protected
  def setup_metro_areas_for_cloud
    @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "users_count > 0", :order => "users_count DESC", :limit => 100)
    @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
  end

  def setup_locations_for(user)
    metro_areas = states = []
    states = user.country.states if user.country
    metro_areas = user.state.metro_areas.all(:order => "name") if user.state

    return metro_areas, states
  end
end
