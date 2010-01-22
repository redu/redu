class CourseObserver < ActiveRecord::Observer
  
  
  
  def after_create(course)
    user = course.owner
    Log.create(:table => 'course',
    :action => 'create',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => course.name,
    :object_id => course.id,
    :comment => 'Aula Criada...')
  end
  
  
  def after_destroy(course)
     Log.delete_all(["object_id = ?", course.id])
  end
  
  def after_update(course)
    user = course.owner
    Log.create(:table => 'course',
    :action => 'update',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => course.name,
    :object_id => course.id,
    :comment => 'Aula Atualizada...')
  end
 
  
end
