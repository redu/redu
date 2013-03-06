class SpaceSearch < Search
  def initialize
    super(Space)
  end

  def self.perform(query, per_page, format = nil, page = nil)
    searcher = SpaceSearch.new
    # Instant search não necessita dos includes
    includes = format == "json" ? [] : [{ :course => [:user_course_associations,
                                                      :environment, :owner] }]

    # Busca por Spaces não terá paginação automatica pois o resultado
    # será filtrado posteriormente
    search_object = searcher.search({ :query => query, :page => nil,
                                      :per_page => nil, :include => includes,
                                      :order => :desc })
  end
end
