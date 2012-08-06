shared_examples_for "a basic content variables proxy" do
  before do
    hash = { :basic_content => true, :base_course_id => @base_course.id }
    @params = @params.merge hash
  end

  it "keeps basic content variables" do
    post :create, @params
    assigns[:has_basic_content].should be_true
    assigns[:base_course_id].should_not be_nil
  end
end