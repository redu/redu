class SpaceSearch < Search
  def initialize(per_page)
    super(Space, :per_page => per_page)
  end

  def perform(query, page)
    search({ :query => query, :page => page,
             :include => [:users, :subjects, :teachers, :owner, :tags,
                          { :course => :environment }] })
  end
end
