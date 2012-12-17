class CourseSearch < Search
  def initialize
    super(Course, :per_page => 10)
  end

  def perform(query, page)
    search({ :query => query, :page => page,
             :include => [:audiences, :spaces, :tags, :environment, :owner,
                          :teachers] })
  end
end
