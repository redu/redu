class ExamObserver < ActiveRecord::Observer
  
  def after_create(exam)
    user = User.find(exam.owner_id)
    Log.create(:table => 'exam',
    :action => 'create',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => exam.name,
    :object_id => exam.id,
    :comment => 'Exame Adicionado...')
  end
  
  
  def after_destroy(exam)
     Log.delete_all(["object_id = ?", exam.id])
  end
  
  def after_update(exam)
    user = User.find(exam.owner_id)
    Log.create(:table => 'exam',
    :action => 'update',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => exam.name,
    :object_id => exam.id,
    :comment => 'Exame Atualizado...')
  end
  
end
