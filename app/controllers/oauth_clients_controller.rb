class OauthClientsController < BaseController
  layout 'new_application'
  before_filter :login_required

  def index
    @user = User.find(params[:user_id])
    @client_applications = @user.client_applications
  end

  def new
    @user = User.find(params[:user_id])
    @client_application = ClientApplication.new
  end

  def create
    @user = User.find(params[:user_id])
    @client_application = @user.client_applications.build(params[:client_application])

    if @client_application.save
      flash[:notice] = "O aplicativo foi criado."
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "new"
    end
  end

  def update
    @client_application = ClientApplication.find(params[:id])
    if @client_application.update_attributes(params[:client_application])
      flash[:notice] = "O aplicativo foi atualizado."
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @client_application = ClientApplication.find(params[:id])
    @client_application.destroy
    flash[:notice] = "O aplicativo foi removido."
    redirect_to :action => "index"
  end

  def show
    @user = User.find(params[:user_id])
    @client_application = @user.client_applications.find(params[:id])
  end

  def edit
    @user = User.find(params[:user_id])
    @client_application = @user.client_applications.find(params[:id])
  end

  private

  def login_required
    #authorize! :manage, :client_applications
  end
end
