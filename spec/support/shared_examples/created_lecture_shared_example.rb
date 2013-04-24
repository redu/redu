shared_examples_for "created lecture" do
  it "creates a lecture" do
    expect {
      post :create, create_params
    }.to change(Lecture, :count).by(1)
  end

  it "creates a lectureable (Page)" do
    expect {
      post :create, create_params
    }.to change(lectureable_class, :count).by(1)
  end

  it "associates a lectureable (Page) to a lecture" do
    post :create, create_params
    lecture = Lecture.last
    lectureable = lectureable_class.last

    lecture.name.should == create_params[:lecture][:name]
    lecture.lectureable.should == lectureable
  end
end
