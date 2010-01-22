class ResourceObserver < ActiveRecord::Observer
  
   def after_create(resource)
    user = User.find(resource.owner_id)
    Log.create(:table => 'resource',
    :action => 'create',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => resource.title,
    :object_id => resource.id,
    :comment => 'Material Adicionado...')
  end
  
  
  def after_destroy(resource)
     Log.delete_all(["object_id = ?", resource.id])
  end
  
  def after_update(resource)
    user = User.find(resource.owner_id)
    Log.create(:table => 'resource',
    :action => 'update',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => resource.title,
    :object_id => resource.id,
    :comment => 'Material Atualizado...')
  end
  
end
