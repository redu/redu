class EnvironmentSearch < Search
  def initialize
    super(Environment)
  end

  def self.perform(query, per_page, format = nil, page = nil)
    searcher = EnvironmentSearch.new
    # Instant search não necessita dos includes
    includes = format == "json" ? [] : [:user_environment_associations, :courses]

    searcher.search({ :query => query, :page => page,
                      :per_page => per_page, :include => includes })
  end
end
