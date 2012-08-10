module CacheSpecHelper
  def performing_cache(*initial_caches)
    ActionController::Base.perform_caching = true
    # Cria as caches que já devem existir inicialmente
    initial_caches.each do |cache_identifier|
      Rails.cache.write(cache_identifier, "I'm a cache")
    end

    yield Rails.cache
  ensure
    ActionController::Base.perform_caching = false
    Rails.cache.clear
  end
end
