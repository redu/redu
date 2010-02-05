class ExamObserver < ActiveRecord::Observer
  
  def after_create(exam)
    user = User.find(exam.author_id)
    Log.create(:table => 'exam',
    :action => 'create',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => exam.name,
    :object_id => exam.id,
    :comment => 'Exame Adicionado...')
    thepoints = AppConfig.points['created_exam']
    new_score = user.score + thepoints
    user.score = new_score
    user.save
  end
  
  
  def after_destroy(exam)
     Log.delete_all(["object_id = ?", exam.id])
  end
  
  def after_update(exam)
    user = User.find(exam.author_id)
    Log.create(:table => 'exam',
    :action => 'update',
    :actor_name => user.login,
    :actor_id => user.id,
    :object_name => exam.name,
    :object_id => exam.id,
    :comment => 'Exame Atualizado...')
    thepoints = AppConfig.points['updated_exam']
    new_score = user.score + thepoints
    user.score = new_score
    user.save
  end
  
end
