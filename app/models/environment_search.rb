class EnvironmentSearch < Search
  def initialize
    super(Environment)
  end

  def self.perform(query, per_page, format = nil, page = nil)
    searcher = EnvironmentSearch.new

    # Instant search não necessita dos includes, deve procurar apenas pelos nomes
    if format == "json"
      fields = :name
      includes = []
    else
      includes = [:user_environment_associations, :courses]
    end

    searcher.search({ :query => query, :page => page,
                      :per_page => per_page, :include => includes,
                      :fields => fields })
  end
end
