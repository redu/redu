# -*- encoding : utf-8 -*-
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

  context "when creating asset reports" do
    let(:lecture) { mock_lecture_initialize }

    context "when lecture is not finalized" do
      before do
        lecture.stub(:finalized?) { false }
      end

      it "should not invoke Lecture#create_asset_report" do
        lecture.should_not_receive(:create_asset_report)
        post :create, create_params
      end
    end

    context "when lecture is finalized" do
      before do
        lecture.stub(:finalized?) { true }
      end

      it "should invoke Lecture#create_asset_report" do
        lecture.should_receive(:create_asset_report)
        post :create, create_params
      end
    end
  end

  def mock_lecture_initialize
    lecture = FactoryGirl.create(:lecture)
    Lecture.stub(:new).and_return(lecture)
    lecture
  end
end
