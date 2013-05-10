class UserObserver < ActiveRecord::Observer
  def before_update(user)
    Log.setup(user, :action => :update, :text => "atualizou o perfil")
  end
end
