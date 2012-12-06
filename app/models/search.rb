class Search
  attr_reader :klass, :config

  def initialize(model, opts={})
    @klass = model
    @config = { :per_page => 10 }.merge(opts)
  end

  def search(opts)
    klass.send("search", { :include => opts[:include] }) do
      fulltext opts[:query]
      paginate :page => opts[:page], :per_page => config[:per_page]
    end
  end
end
