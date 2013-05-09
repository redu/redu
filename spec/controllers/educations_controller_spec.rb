require 'spec_helper'
require 'authlogic/test_case'

describe EducationsController do
  before do
    @user = Factory(:user)
    login_as @user
  end

  describe "POST 'create'" do
    before do
      @post_params = {:locale => "pt-BR", :format => "js",
        :user_id => @user.id, :high_school =>
        { :institution => "Institution", "end_year(1i)" => "2010",
          "end_year(2i)" => "1", "end_year(3i)" => "1",
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua." }}
    end

    context "when success" do
      it "should be successful" do
        post :create, @post_params
        response.should be_success
      end

      it "creates an education" do
        expect {
          post :create, @post_params
        }.to change(Education, :count).by(1)
        Education.last.user.should == @user
        Education.last.educationable.should == HighSchool.last
      end

      it "@high_school should be a new one (HighSchool.new)" do
        post :create, @post_params
        assigns[:high_school].institution.should be_nil
        assigns[:high_school].description.should be_nil
        assigns[:high_school].end_year.should be_nil
        assigns[:high_school].created_at.should be_nil
        assigns[:high_school].updated_at.should be_nil
      end

      [:high_school, :higher_education, :complementary_course,
        :event_education].each do |var|
        it "assigns @#{var}" do
          post :create, @post_params
          assigns[var].should_not be_nil
        end
      end
    end

    context "when failing" do
      before do
        @post_params[:high_school][:institution] = ""
      end

      [:high_school, :higher_education, :complementary_course,
        :event_education].each do |var|
        it "assigns @#{var}" do
          post :create, @post_params
          assigns[var].should_not be_nil
        end
      end

      it "does NOT create an education" do
        expect {
          post :create, @post_params
        }.to_not change(Education, :count)
      end

      it "does NOT create an high_school" do
        expect {
          post :create, @post_params
        }.to_not change(HighSchool, :count)
      end

      it "@high_school is the educationable" do
        post :create, @post_params
        assigns[:high_school].description.should ==
          @post_params[:high_school][:description]
      end
    end

    context "with education of kind higher_education" do
      before do
        @post_params.delete :high_school
        @post_params[:higher_education] = { :kind => "technical",
          :course => "Course", :institution => "Inst.",
          "start_year(1i)" => "2009", "start_year(2i)" => "1",
          "start_year(3i)" => "1", "end_year(1i)" => "2010",
          "end_year(2i)" => "1", "end_year(3i)" => "1",
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam."}
      end

      it "creates an education" do
        expect {
          post :create, @post_params
        }.to change(Education, :count).by(1)
        Education.last.user.should == @user
        Education.last.educationable.should == HigherEducation.last
      end
    end

    context "with education of kind complementary_course" do
      before do
        @post_params.delete :high_school
        @post_params[:complementary_course] = { :course => "Course",
          :institution => "Institution", :workload => 40,
          "year(1i)" => "2009", "year(2i)" => "1", "year(3i)" => "1",
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam."}
      end

      it "creates an education" do
        expect {
          post :create, @post_params
        }.to change(Education, :count).by(1)
        Education.last.user.should == @user
        Education.last.educationable.should == ComplementaryCourse.last
      end
    end

    context "with education of kind event_education" do
      before do
        @post_params.delete :high_school
        @post_params[:event_education] = { :name => "Event",
          :role => "participant", "year(1i)" => "2009",
          "year(2i)" => "1", "year(3i)" => "1" }
      end

      it "creates an education" do
        expect {
          post :create, @post_params
        }.to change(Education, :count).by(1)
        Education.last.user.should == @user
        Education.last.educationable.should == EventEducation.last
      end
    end
  end

  describe "POST 'update'" do
    before do
      @education = Factory(:education, :user => @user)
      @post_params = { :locale => "pt-BR", :format => "js",
        :user_id => @user.id, :id => @education.id,
        :high_school => { :institution => "New Inst." }}
    end

    context "when successful" do
      before do
        post :update, @post_params
      end

      it "should be successful" do
        response.should be_success
      end

      it "updates the educationable" do
        HighSchool.last.institution.should ==
          @post_params[:high_school][:institution]
      end

      it "assigns @high_school" do
        assigns[:high_school].should_not be_nil
      end
    end

    context "when failing" do
      before do
        @post_params[:high_school][:institution] = ""
        @old_institution = @education.educationable.institution
        post :update, @post_params
      end

      it "does NOT update the educationable" do
        HighSchool.last.institution.should == @old_institution
        assigns[:education].should_not be_valid
        assigns[:education].errors[:educationable].should_not be_empty
      end
    end

    context "with education of kind higher_education" do
      before do
        higher_education = Factory(:higher_education)
        @education = Factory(:education, :educationable => higher_education,
                             :user => @user)
        @post_params = { :locale => "pt-BR", :format => "js",
          :user_id => @user.id, :id => @education.id,
          :higher_education => { :institution => "New Inst." }}
        post :update, @post_params
      end

      it "updates the educationable" do
        HigherEducation.last.institution.should ==
          @post_params[:higher_education][:institution]
      end

      it "assigns @higher_education" do
        assigns[:higher_education].should_not be_nil
      end
    end

    context "with education of kind complementary_course" do
      before do
        complementary_course = Factory(:complementary_course)
        @education = Factory(:education, :educationable => complementary_course,
                             :user => @user)
        @post_params = { :locale => "pt-BR", :format => "js",
          :user_id => @user.id, :id => @education.id,
          :complementary_course => { :institution => "New Inst." }}
        post :update, @post_params
      end

      it "updates the educationable" do
        ComplementaryCourse.last.institution.should ==
          @post_params[:complementary_course][:institution]
      end

      it "assigns @complementary_course" do
        assigns[:complementary_course].should_not be_nil
      end
    end

    context "with education of kind event_education" do
      before do
        event_education = Factory(:event_education)
        @education = Factory(:education, :educationable => event_education,
                             :user => @user)
        @post_params = { :locale => "pt-BR", :format => "js",
          :user_id => @user.id, :id => @education.id,
          :event_education => { :name => "New name" }}
        post :update, @post_params
      end

      it "updates the educationable" do
        EventEducation.last.name.should ==
          @post_params[:event_education][:name]
      end

      it "assigns @event_education" do
        assigns[:event_education].should_not be_nil
      end
    end
  end

  describe "POST 'destroy'" do
    before do
      @education = Factory(:education, :user => @user)
      @params = {:locale => "pt-BR", :format => "js", :user_id => @user.id,
        :id => @education.id }
    end

    it "should be successful" do
      post :destroy, @params
      response.should be_success
    end

    it "destroys the education" do
      expect {
        post :destroy, @params
      }.to change(Education, :count).by(-1)
    end

    it "destroys the educationable" do
      expect {
        post :destroy, @params
      }.to change(HighSchool, :count).by(-1)
    end

    context "with education of kind higher_education" do
      before do
        higher_education = Factory(:higher_education)
        @education = Factory(:education, :educationable => higher_education,
                             :user => @user)
        @params = {:locale => "pt-BR", :format => "js", :user_id => @user.id,
          :id => @education.id }
      end

      it "destroys the educationable" do
        expect {
          post :destroy, @params
        }.to change(HigherEducation, :count).by(-1)
      end
    end

    context "with education of kind complementary_course" do
      before do
        complementary_course = Factory(:complementary_course)
        @education = Factory(:education, :educationable => complementary_course,
                             :user => @user)
        @params = {:locale => "pt-BR", :format => "js", :user_id => @user.id,
          :id => @education.id }
      end

      it "destroys the educationable" do
        expect {
          post :destroy, @params
        }.to change(ComplementaryCourse, :count).by(-1)
      end
    end

    context "with education of kind event_education" do
      before do
        event_education = Factory(:event_education)
        @education = Factory(:education, :educationable => event_education,
                             :user => @user)
        @params = {:locale => "pt-BR", :format => "js", :user_id => @user.id,
          :id => @education.id }
      end

      it "destroys the educationable" do
        expect {
          post :destroy, @params
        }.to change(EventEducation, :count).by(-1)
      end
    end
  end

end
