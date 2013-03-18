class UserSearch < Search
  def initialize
    super(User)
  end

  def self.perform(query, per_page, format = nil, page = nil)
    searcher = UserSearch.new

    # Instant search não necessita dos includes, deve procurar apenas pelos nomes
    if format == "json"
      fields = :name
      includes = []
    else
      includes = [:experiences, :friends, :friendships,
                  { :educations  => :educationable }]
    end

    searcher.search({ :query => query, :page => page,
                      :per_page => per_page, :include => includes,
                      :fields => fields })
  end
end
