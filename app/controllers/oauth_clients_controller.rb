class OauthClientsController < BaseController
  layout 'new_application'

  before_filter :set_nav_global_context

  def index
    @user = User.find(params[:user_id])
    authorize! :manage, @user
    @client_applications = @user.client_applications
  end

  def new
    @user = User.find_by_id(params[:user_id]) || current_user
    authorize! :manage, @user
    @client_application = ClientApplication.new
  end

  def create
    @user = User.find(params[:user_id])
    @client_application = \
      @user.client_applications.build(params[:client_application])
    authorize! :manage, @client_application

    if @client_application.save
      flash[:notice] = "O aplicativo foi criado."
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:user_id])
    @client_application = ClientApplication.find(params[:id])
    authorize! :manage, @client_application

    if @client_application.update_attributes(params[:client_application])
      flash[:notice] = "O aplicativo foi atualizado."
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @client_application = ClientApplication.find(params[:id])
    authorize! :manage, @client_application

    @client_application.destroy
    flash[:notice] = "O aplicativo foi removido."
    redirect_to :action => "index"
  end

  def show
    @user = User.find(params[:user_id])
    @client_application = @user.client_applications.find(params[:id])
    authorize! :manage, @client_application
  end

  def edit
    @user = User.find(params[:user_id])
    @client_application = @user.client_applications.find(params[:id])
    authorize! :manage, @client_application
  end

  def set_nav_global_context
    content_for :nav_global_context, "new_users"
  end
end
