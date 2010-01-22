class UserObserver < ActiveRecord::Observer
  
  def after_create(user)
    Log.create(:table => 'user',
    :action => 'create',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => user.login,
    :object_id => user.id,
    :comment => 'Usuário Adicionado...')
  end
  
  
  def after_destroy(user)
     Log.delete_all(["actor_id = ?", user.id])
  end
  
  def after_update(user)
    Log.create(:table => 'user',
    :action => 'update',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => user.login,
    :object_id => user.id,
    :comment => 'Usuário Atualizado...')
  end
  
end
