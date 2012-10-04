shared_examples_for "pagination" do
  before do
    per_page = entities.count / 2
    Kaminari.config.default_per_page = per_page
  end

  it "should default to #{Kaminari.config.default_per_page} per page" do
    get(*params)
    parse(response.body).count.should == Kaminari.config.default_per_page
  end

  it "should accept page parameter" do
    params.last.merge!(:page => 2)
    get(*params)
    parse(response.body).count.should == Kaminari.config.default_per_page
  end

  it "should return empty list when the page doesnt exist" do
    params.last.merge!(:page => 4)
    get(*params)
    parse(response.body).count.should == 0
  end

  after do
    Kaminari.config.default_per_page = 25
  end
end
