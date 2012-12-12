class SpaceSearch < Search
  def initialize
    super(Space)
  end

  def self.perform(query, page = nil, per_page = 10)
    searcher = SpaceSearch.new
    searcher.search({ :query => query, :page => page, :per_page => per_page,
      :include => [:users, :subjects, :teachers, :owner, :tags, { :course => :environment }] })
  end
end
