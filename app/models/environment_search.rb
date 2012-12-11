class EnvironmentSearch < Search
  def initialize(per_page)
    super(Environment, :per_page => per_page)
  end

  def perform(query, page)
    search({ :query => query, :page => page,
             :include => [:users, :courses, :tags, :administrators] })
  end
end
