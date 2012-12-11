class UserSearch < Search
  def initialize(per_page = 10)
    super(User, :per_page => per_page)
  end

  def perform(query, page)
    search({ :query => query, :page => page,
             :include => [:experiences, :tags, { :educations  => :educationable }] })
  end
end
