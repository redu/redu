class ExamSweeper < ActionController::Caching::Sweeper
  observe Exam

  def after_create(exam)
    expire_cache_for(exam)
  end
  
  # If our sweeper detects that a exam was updated call this
  def after_update(exam)
    expire_cache_for(exam)
  end
  
  # If our sweeper detects that a exam was deleted call this
  def after_destroy(exam)
    expire_cache_for(exam)
  end
  
#  def expire_cache_for(record)
#    # Expire the footer content
#    expire_action :controller => 'courses', :action => 'show', :id => record.course_id
#  end  
          
end