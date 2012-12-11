class CourseSearch < Search
  def initialize(per_page)
    super(Course, :per_page => per_page)
  end

  def perform(query, page)
    search({ :query => query, :page => page,
             :include => [:users, :audiences, :spaces, :tags, :environment,
                          :owner, :teachers] })
  end
end
