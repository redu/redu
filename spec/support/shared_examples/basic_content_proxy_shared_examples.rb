shared_examples_for "a basic content variables proxy" do
  before do
    hash = { :basic_content => "true", :base_course_id => @base_course.id }
    @params = @params.merge hash
    post :create, @params
  end

  it "keeps has_basic_content flag" do
    assigns[:has_basic_content].should be_true
  end

  it "keeps the base course id" do
    assigns[:base_course_id].should_not be_nil
  end
end