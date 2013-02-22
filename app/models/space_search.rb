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
                                      :per_page => nil, :include => includes })
  end

  # Filtra somente os spaces que o usuário tem acesso
  # pagina de acordo com os parâmetros recebidos
  def self.filter_and_paginate_my_spaces(collection, user, params)
    my_spaces = collection.select{ |space| user.has_access_to?(space) }

    Kaminari.paginate_array(my_spaces).page(params[:page]).
      per(params[:per_page])
  end
end
