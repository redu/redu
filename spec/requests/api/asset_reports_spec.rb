require 'api_spec_helper'

describe "AssetReports API" do
  let(:subj) { Factory(:complete_subject) }
  let(:course) { subj.space.course }
  let(:token) { _, _, token = generate_token(user); token }
  let(:params) { { :oauth_token => token, :format => 'json' } }

  context "when GET /progress/:id" do
    let(:user) { user_joined_on_course(course, Role[:member]) }
    let(:asset_report) { user.enrollments.first.asset_reports.first }

    before do
      get "/api/progress/#{asset_report.id}", params
    end

    it "should return status 200" do
      response.code.should == "200"
    end

    %w(id finalized updated_at).each do |property|
      it "should have property #{property}" do
        resource = parse(response.body)
        resource.should have_key property
      end
    end

    %w(self user lecture subject).each do |link|
      it "should have link #{link}" do
        resource = parse(response.body)
        href_to(link, resource).should_not be_blank
      end
    end

    it "should return the correct asset_report" do
      resource = parse(response.body)
      resource["id"].should == asset_report.id
      resource["finalized"].should == asset_report.done
    end
  end

  context "when PUT /progress/:id" do
    let(:user) { user_joined_on_course(course, Role[:member]) }
    let(:asset_report) { user.enrollments.first.asset_reports.first }

    let(:put_params) { params.merge(:progress => { :finalized => "true" }) }

    it "should return status 200" do
      put "/api/progress/#{asset_report.id}", put_params
      response.code.should == "200"
    end

    it "should update finalized to true" do
      put "/api/progress/#{asset_report.id}", put_params
      asset_report.reload.done.should be_true
    end

    it "should call update_grade! on enrollment" do
      Enrollment.any_instance.should_receive(:update_grade!).once
      put "/api/progress/#{asset_report.id}", put_params
    end
  end

  context "when listing asset reports" do
    let!(:other_users) do
      (1..2).map { user_joined_on_course(course, Role[:member]) }
    end
    let(:asset_reports) { context.asset_reports }

    context "when GET /lectures/:lecture_id/progress" do
      let(:user) { user_joined_on_course(course, Role[:teacher]) }
      let(:context) { Factory(:lecture, :subject => subj, :owner => user) }


      it_should_behave_like "asset reports listing without filter"
      it_should_behave_like "asset reports listing with filter user_id"
    end

    context "when GET /subjects/:subject_id/progress" do
      let(:user) { user_joined_on_course(course, Role[:teacher]) }
      let(:context) { subj }

      it_should_behave_like "asset reports listing without filter"
      it_should_behave_like "asset reports listing with filter user_id"
    end
  end

  protected

  def user_joined_on_course(course, role)
    u = Factory(:user)
    course.join! u, role
    u
  end
end
