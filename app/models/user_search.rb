class UserSearch < Search
  def initialize
    super(User)
  end

  def self.perform(query, page = nil, per_page = 10)
    searcher = UserSearch.new
    searcher.search({ :query => query, :page => page, :per_page => per_page,
      :include => [:experiences, :tags, :friends, { :educations  => :educationable }] })
  end
end
