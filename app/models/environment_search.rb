class EnvironmentSearch < Search
  def initialize
    super(Environment)
  end

  def self.perform(query, page = nil, per_page = 10)
    searcher = EnvironmentSearch.new
    searcher.search({ :query => query, :page => page, :per_page => per_page,
      :include => [:users, :courses, :tags, :administrators] })
  end
end
