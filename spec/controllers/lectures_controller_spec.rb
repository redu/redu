require 'spec_helper'
require 'authlogic/test_case'

describe LecturesController do
  before do
    User.maintain_sessions = false
    @space = Factory(:space)
    @subject_owner = Factory(:user)
    @space.course.join @subject_owner
    activate_authlogic

    @subject = Factory(:subject, :owner => @subject_owner,
                       :space => @space, :finalized => true,
                       :visible => true)
    @lectures = (1..3).collect { Factory(:lecture,:subject => @subject ,:owner => @subject_owner) }
    @enrolled_user = Factory(:user)
    @space.course.join @enrolled_user
    @subject.enroll @enrolled_user
    UserSession.create @enrolled_user
  end

  context "GET 'show'" do
    context "when Page" do
      before do
        post :show, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id
      end
      it "renders show_page" do
        response.should render_template('lectures/show_page')
      end
    end
    context "when Seminar" do
      before do
        lectureable = @lectures[0].lectureable
        #lectureable = Factory(:seminar)
        lectureable.save
        post :show, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id
      end
      it "renders show_page" do
        pending do
          response.should render_template('lectures/show_seminar')
        end
      end
    end
    context "when Document" do
      before do
        @lectures[0].lectureable = Factory(:document)
        @lectures[0].save
        post :show, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id
      end
      it "renders show_page" do
        response.should render_template('lectures/show_document')
      end
    end
  end

  context "POST 'done'" do
    context "when done = 1" do
      it "marks the actual lecture as done" do
        post :done, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id, :done => "1"

        @lectures[0].asset_reports.of_user(@enrolled_user).last.
          should be_done
      end
    end

    context "when done = 0" do
      it "marks the actual lecture as undone" do
        @lectures[0].asset_reports.of_user(@enrolled_user).last.done = true

        post :done, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id, :done => "0"

        @lectures[0].asset_reports.reload.of_user(@enrolled_user).last.
          should_not be_done
      end
    end

    it "should call update_grade! and update the grade" do
      post :done, :locale => "pt-BR", :id => @lectures[0].id,
        :subject_id => @subject.id, :space_id => @space.id, :done => "1"
      @enrolled_user.student_profiles.first.grade.should == 33.3333
    end

    context 'when html request' do
      it "redirects to lecture show" do
        post :done, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id

        response.should redirect_to(
          space_subject_lecture_path(@space, @subject, @lectures[0]))
      end
    end

    context 'when js request' do
      it "renders done.rjs" do
        post :done, :locale => "pt-BR", :id => @lectures[0].id, :format => 'js',
          :subject_id => @subject.id, :space_id => @space.id

        response.should render_template('lectures/done')
      end
    end
  end

end
