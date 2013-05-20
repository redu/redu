# -*- encoding : utf-8 -*-
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

    it "should return status 204" do
      put "/api/progress/#{asset_report.id}", put_params
      response.code.should == "204"
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

    context "when GET /users/:user_id/progress" do
      let(:user) { user_joined_on_course(course, Role[:member]) }
      let(:context) { user }

      it_should_behave_like "asset reports listing without filter"

      it_should_behave_like "user asset reports listing with filter" do
        let(:lectures_ids) { subj.lectures[0..1].map(&:id) }

        let(:filtered_asset_reports) do
          asset_reports.select { |a| lectures_ids.include? a.lecture_id }
        end
        let(:params_with_filter) { params.merge(:lectures_ids => lectures_ids) }
      end

      context "with many subjects" do
        let(:subjects) { FactoryGirl.create_list(:complete_subject, 2) }

        before do
          subjects.each { |s| s.enroll user }
        end

        it_should_behave_like "user asset reports listing with filter" do
          let(:subjects_ids) { subjects[0..1].map(&:id) }

          let(:filtered_asset_reports) do
            asset_reports.select { |a| subjects_ids.include? a.subject_id }
          end
          let(:params_with_filter) do
            params.merge(:subjects_ids => subjects_ids)
          end
        end
      end
    end
  end

  protected

  def user_joined_on_course(course, role)
    u = Factory(:user)
    course.join! u, role
    u
  end
end
