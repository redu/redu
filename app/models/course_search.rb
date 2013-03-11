class CourseSearch < Search
  def initialize
    super(Course)
  end

  def self.perform(query, per_page, format = nil, page = nil)
    searcher = CourseSearch.new

    # Instant search não necessita dos includes, deve procurar apenas pelos nomes
    if format == "json"
      fields = :name
      includes = [:user_course_associations, :environment,
                  :spaces, :owner]
    end

    searcher.search({ :query => query, :page => page,
                      :per_page => per_page, :include => includes,
                      :fields => fields })
  end
end
