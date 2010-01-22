class ResourceSweeper < ActionController::Caching::Sweeper
  observe Resource

  def after_create(resource)
    expire_cache_for(resource)
  end
  
  # If our sweeper detects that a course was updated call this
  def after_update(resource)
    expire_cache_for(resource)
  end
  
  # If our sweeper detects that a course was deleted call this
  def after_destroy(resource)
    expire_cache_for(resource)
  end
  
#  def expire_cache_for(record)
#    # Expire the footer content
#    expire_action :controller => 'courses', :action => 'show', :id => record.course_id
#  end  
          
end