class SpaceSearch < Search
  def initialize
    super(Space)
  end

  def self.perform(query, per_page, format = nil, page = nil)
    searcher = SpaceSearch.new

    # Instant search não necessita dos includes, deve procurar apenas pelos nomes
    if format == "json"
      fields = :name
      includes = []
    else
      includes = [{ :course => [:user_course_associations,
                                :environment, :owner] }]
    end

    # Busca por Spaces não terá paginação automatica pois o resultado
    # será filtrado posteriormente
    search_object = searcher.search({ :query => query, :page => nil,
                                      :per_page => nil, :include => includes,
                                      :fields => fields})
  end
end
