class EnvironmentSearch < Search
  def initialize
    super(Environment)
  end

  def self.perform(query, format = nil, page = nil, per_page = 10)
    searcher = EnvironmentSearch.new
    # Instant search não necessita dos includes
    includes = format == "json" ? [] : [:user_environment_associations,
                                        :courses, :owner]

    searcher.search({ :query => query, :page => page,
                      :per_page => per_page, :include => includes })
  end
end
