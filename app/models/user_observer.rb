class UserObserver < ActiveRecord::Observer
  def before_update(user)
    Log.setup(user, :action => :update, :text => "atualizou o perfil")
  end

  def after_create(user)
    UserNotifier.user_signedup(user).deliver

    environment = Environment.find_by_path('ava-redu')

    environment.courses.each { |c| c.join(user) } if environment

    # criando AccessToken do OAuth para ReduViz
    application = ClientApplication.where(:name => "ReduViz").first
    AccessToken.create(:client_application => application,
                       :user => user)
  end
end
