class UserObserver < ActiveRecord::Observer
  def before_update(user)
    Log.setup(user, :action => :update, :text => "atualizou o perfil")
  end

  def after_create(user)
    UserNotifier.user_signedup(user).deliver
  end
end
