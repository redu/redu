class FriendshipObserver < ActiveRecord::Observer
  def after_update(friendship)
    Log.setup(friendship, :action => :update, :text => "adicionou a sua rede de contatos")
  end
end
