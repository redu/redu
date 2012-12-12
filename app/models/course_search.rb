class CourseSearch < Search
  def initialize
    super(Course)
  end

  def self.perform(query, page = nil, per_page = 10)
    searcher = CourseSearch.new
    searcher.search({ :query => query, :page => page, :per_page => per_page,
      :include => [:users, :audiences, :spaces, :tags, :environment, :owner, :teachers] })
  end
end
