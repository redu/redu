# -*- encoding : utf-8 -*-
shared_examples_for "a lecture" do
  it "should return status 200" do
    response.code.should == "200"
  end

  %w(id name position rating view_count type created_at updated_at).each do |property|
    it "should have the property #{property}" do
      resource = parse(response.body)
      resource.should have_key property
    end
  end

  %w(self self_link subject space course environment).each do |link|
    it "should have the link #{link}" do
      lecture = parse(response.body)
      href_to(link, lecture).should_not be_blank
    end
  end
end
