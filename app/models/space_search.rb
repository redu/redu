class SpaceSearch < Search
  def initialize
    super(Space, :per_page => 10)
  end

  def perform(query, page)
    search({ :query => query, :page => page,
             :include => [:subjects, :teachers, :owner, :tags,
                          { :course => :environment }] })
  end
end
