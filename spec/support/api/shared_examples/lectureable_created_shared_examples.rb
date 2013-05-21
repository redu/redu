# -*- encoding : utf-8 -*-
shared_examples_for "a lecture created" do
  before { post url, lecture_params }

  it "should return 201 HTTP code" do
    response.code.should == "201"
  end

  it "should return the correct type" do
    parse(response.body)['type'].should == lecture_params[:lecture][:type]
  end

  it "should have the correct mimetype" do
    parse(response.body)["mimetype"].should == mimetype
  end
end
