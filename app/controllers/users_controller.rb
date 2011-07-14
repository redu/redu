class UsersController < BaseController

  after_filter :create_activity, :only => [:update]
  load_and_authorize_resource :except => [:forgot_password,
    :forgot_username, :resend_activation, :activate],
    :find_by => :login

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

  def show_log_activity
    current_user.log_activity
    format.js { render_endless 'statuses/item', @statuses, '#statuses > ol' }
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
    if @user and @user.activated_at
      flash[:notice] = "Sua conta já foi ativada. Utilize seu login e senha para entrar no Redu."
      redirect_to application_path
      return
    elsif @user and @user.activate
      UserSession.create(@user) if current_user.nil?

      redirect_to home_user_path(@user)
      flash[:notice] = t :thanks_for_activating_your_account
      return
    end
    flash[:error] = t(:account_activation_error, :email => Redu::Application.config.email)
    redirect_to signup_path
  end

  def deactivate
    @user.deactivate
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t :deactivate_completed
    redirect_to login_path
  end

  def show
    if @user.removed
      redirect_to removed_page_path and return
    end

    @statuses = @user.profile_activity(params[:page])
    @statusable = @user
    @status = Status.new

    respond_to do |format|
      format.html
      format.js { render_endless 'statuses/item', @statuses, '#statuses > ol' }
    end
  end

  def contacts_endless
    @contacts = @user.friends.page(params[:page]).per(8)

    respond_to do |format|
      format.js { render_sidebar_endless 'users/item_medium_24', @contacts,
        '.connections', "Mostrando os <X> últimos contatos de #{@user.first_name}" }
    end
  end

  def environments_endless
    @environments = @user.environments.page(params[:page]).per(4)

    respond_to do |format|
      format.js { render_sidebar_endless 'environments/item_medium',
        @environments, '.environments > ul',
        "Mostrando os <X> últimos ambientes de #{@user.first_name}",
        "sec-sidebar-endless" }
    end
  end

  def new
    @user         = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    @inviter_id   = params[:id]
    @inviter_code = params[:code]

    respond_to do |format|
      format.html do
        render :new, :layout => 'clean'
      end
    end
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      @user.create_settings!
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

      flash[:notice] = t(:email_signup_thanks, :email => @user.email)
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
          flash[:notice] = t :thanks_youre_now_logged_in
          redirect_back_or_default user_path(current_user)
        else
          flash[:notice] = t :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again
          render :action => :new
        end
      else
        render :template => 'users/new', :layout => 'clean'
      end
    end
  end

  def edit
    @experience = Experience.new
    @high_school = HighSchool.new
    @user.social_networks.build
    respond_to do |format|
      format.html
    end
  end

  def update
    @user.attributes    = params[:user]

    unless params[:metro_area_id].blank?
      @user.metro_area  = MetroArea.find(params[:metro_area_id])
      @user.state       = (@user.metro_area && @user.metro_area.state) ? @user.metro_area.state : nil
      @user.country     = @user.metro_area.country if (@user.metro_area && @user.metro_area.country)
    else
      @user.metro_area = @user.state = @user.country = nil
    end

    @user.tag_list = params[:tag_list] || ''

    if @user.errors.empty? && @user.save
      respond_to do |format|
        format.html do
          flash[:notice] = t :your_changes_were_saved
          unless params[:welcome]
            redirect_to(edit_user_path(@user))
          else
            redirect_to(:action => "welcome_#{params[:welcome]}", :id => @user)
          end
        end
      end
    else
        render 'users/edit'
    end
  rescue ActiveRecord::RecordInvalid
      render 'users/edit'
  end

  def update_account
    # alteracao de senha na conta do usuario
    if params.has_key? "current_password" and !params[:current_password].empty?
      @flag = false
      authenticated = UserSession.new(:login => @user.login,
                                      :password => params[:current_password]).save

      if authenticated
        @user.attributes  = params[:user]
        @user.save
      else
        @current_password = params[:current_password]
        @user.errors.add(:base, "A senha atual está incorreta")
        @flag = true
      end

      if params[:user].has_key? "password" and params[:user][:password].empty?
        @user.errors.add(:base, "A nova senha não pode ser em branco")
      end
    else
      params[:user][:password] = @user.password
      @user.attributes  = params[:user]
      @user.save
    end

    if @user.errors.empty?
      flash[:notice] = t :your_changes_were_saved
      redirect_to(account_user_path(@user))
    else
      render 'users/account'
    end
  end

  def destroy
    @user.destroy
    flash[:notice] = t :the_user_was_deleted
    redirect_to home_path and return
  end

  def change_profile_photo
    #@user   = User.find(params[:id])
    @photo  = Photo.find(params[:photo_id])
    @user.avatar = @photo

    if @user.save!
      flash[:notice] = t :your_changes_were_saved
      redirect_to user_photo_path(@user, @photo)
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end

  def crop_profile_photo
    unless @photo = @user.avatar
      flash[:notice] = t :no_profile_photo
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

  def edit_pro_details
  end

  def update_pro_details
    @user.add_offerings(params[:offerings]) if params[:offerings]
    @user.attributes = params[:user]

    if @user.save!
      respond_to do |format|
        format.html {
          flash[:notice] = t :your_changes_were_saved
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
    render :template => "users/signup_completed", :layout => "clean"
  end

  def invite
  end

  def welcome_complete
    flash[:notice] = t(:walkthrough_complete, :site => Redu::Application.config.name)
    redirect_to user_path
  end

  def forgot_password
    return unless request.post?
    @user = User.find_by_email(params[:email])

    if @user && @user.reset_password
      UserNotifier.reset_password(@user).deliver
      @user.save

      # O usuario estava ficando logado, apos o comando @user.save.
      # Destruindo sessao caso ela exista.
      if UserSession.find
        UserSession.find.destroy
      end

      redirect_to home_path
      flash[:info] = t :your_password_has_been_reset_and_emailed_to_you
    else
      flash[:error] = t :sorry_we_dont_recognize_that_email_address
    end
  end

  def forgot_username
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      UserNotifier.forgot_username(@user).deliver
      redirect_to home_path
      flash[:info] = t :your_username_was_emailed_to_you
    else
      flash[:error] = t :sorry_we_dont_recognize_that_email_address
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
      flash[:notice] = t :activation_email_resent_message
      UserNotifier.signup_notification(@user).deliver
      redirect_to application_path and return
    else
      flash[:notice] = t :activation_email_not_sent_message
    end
  end

  def assume
    self.current_user = User.find(params[:id])
    redirect_to user_path(current_user)
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
      format.html
      format.js { render_endless 'statuses/item', @statuses, '#statuses > ol' }
    end
  end

  def mural
    @friends = current_user.friends.paginate(:page => 1, :per_page => 9)
    @statuses = current_user.statuses.not_response.
      paginate(:page => params[:page], :per_page => 10)
    @status = Status.new

    respond_to do |format|
      format.html
      format.js { render_endless 'statuses/item', @statuses, '#statuses > ol' }
    end
  end

  def account
    respond_to do |format|
      format.html
    end

  end

  # Dada uma palavra-chave retorna json com usuários que possuem aquela palavra.
  def auto_complete
    if params[:q] # Usado em invitations: todos os users
      @users = User.with_keyword(params[:q])
      @users = @users.map do |u|
        { :id => u.id, :name => u.display_name, :avatar_32 => u.avatar.url(:thumb_32) }
      end
    elsif params[:tag] # Usado em messages: somente amigos
      @users = current_user.friends.with_keyword(params[:tag])
      @users = @users.map do |u|
        {:key => "<img src=\"#{ u.avatar(:thumb_32) }\"/> #{ u.first_name }", :value => u.id}
      end
    end

    respond_to do |format|
      format.js do
        render :json => @users
      end
    end
  end
end
