class UserSearch < Search
  def initialize
    super(User, :per_page => 10)
  end

  def perform(query, page)
    search({ :query => query, :page => page,
             :include => [:experiences, :tags, { :educations  => :educationable }] })
  end
end
