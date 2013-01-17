shared_examples_for "lecture" do
  it "should return status 200" do
    response.code.should == "200"
  end

  it "should have the correct properties" do
    resource = parse(response.body)
    %w(id name position rating view_count type lectureable created_at
      updated_at).each do |property|
        resource.should have_key property
      end
  end

  it "should have the correct links" do
    links = parse(response.body)['links'].collect { |l| l.fetch "rel" }
    %w(self self_link subject space course environment).each do |link|
      links.should include link
    end
  end
end
