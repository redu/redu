class OauthClientsController < BaseController
  layout 'new_application'
  before_filter :login_required

  def index
    @client_applications = current_user.client_applications
    @tokens = current_user.tokens.find :all, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null'
  end

  def new
    @user = User.find(params[:user_id])
    @client_application = ClientApplication.new
  end

  def create
    @user = User.find(params[:user_id])
    @client_application = @user.client_applications.build(params[:client_application])

    if @client_application.save
      flash[:notice] = "Registered the information successfully"
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "new"
    end
  end

  def update
    @client_application = ClientApplication.find(params[:id])
    if @client_application.update_attributes(params[:client_application])
      flash[:notice] = "Updated the client information successfully"
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @client_application.destroy
    flash[:notice] = "Destroyed the client application registration"
    redirect_to :action => "index"
  end

  private

  def login_required
    authorize! :manage, :client_applications
  end
end
