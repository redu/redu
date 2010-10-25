class SpaceSweeper < ActionController::Caching::Sweeper
  observe Space

  def after_create(school)
    expire_cache_for(school)
  end

  # If our sweeper detects that a school was updated call this
  def after_update(school)
    expire_cache_for(school)
  end

  # If our sweeper detects that a school was deleted call this
  def after_destroy(school)
    expire_cache_for(school)
  end
end
