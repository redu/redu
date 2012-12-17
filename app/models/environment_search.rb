class EnvironmentSearch < Search
  def initialize
    super(Environment, :per_page => 10)
  end

  def perform(query, page)
    search({ :query => query, :page => page,
             :include => [:administrators, :courses, :tags] })
  end
end
