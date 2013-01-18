shared_examples_for "lecture" do
  it "should return status 200" do
    response.code.should == "200"
  end

  %w(id name position rating view_count type lectureable created_at
      updated_at).each do |property|
    it "should have the property #{property}" do
      resource = parse(response.body)
      resource.should have_key property
    end
  end

  %w(self self_link subject space course environment).each do |link|
    it "should have the link #{link}" do
      links = parse(response.body)['links'].collect { |l| l.fetch "rel" }
      links.should include link
    end
  end
end
