class SpaceSweeper < ActionController::Caching::Sweeper
  observe Space

  def after_create(space)
    expire_cache_for(space)
  end

  # If our sweeper detects that a space was updated call this
  def after_update(space)
    expire_cache_for(space)
  end

  # If our sweeper detects that a space was deleted call this
  def after_destroy(space)
    expire_cache_for(space)
  end
end
