module CacheSpecHelper
  def performing_cache
    ActionController::Base.perform_caching = true
    yield Rails.cache
    ActionController::Base.perform_caching = false
  end
end
