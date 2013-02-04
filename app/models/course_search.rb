class CourseSearch < Search
  def initialize
    super(Course)
  end

  def self.perform(query, format = nil, page = nil, per_page = 10)
    searcher = CourseSearch.new
    # Instant search não necessita dos includes
    includes = format == "json" ? [] : [:user_course_associations, :environment,
                                        :spaces, :owner]

    searcher.search({ :query => query, :page => page,
                      :per_page => per_page, :include => includes })
  end
end
