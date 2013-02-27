shared_examples_for "a canvas" do
  %w(current_url name created_at updated_at id links).each do |attr|
    it "should have #{attr} property" do
      resource = parse(response.body)
      resource.should have_key attr
    end
  end

  %w(self raw self_link).each do |link|
    it "should have the link #{link}" do
      lecture = parse(response.body)
      href_to(link, lecture).should_not be_blank
    end
  end
end
