require "spec_helper"

describe "Dashboard" do
  context "when not authorized" do
    before do
      @environment = Factory(:environment)
      @course = Factory(:course, :environment => @environment,
                        :owner => @environment.owner)
      3.times.collect do
        u = Factory(:user)
        @course.join(u, Role[:teacher])
      end
    end

    context "GET teacher_participation" do
      it "should return 401 (unauthorized) HTTP code" do
        get "api/dashboard/teacher_participation",
          :course_id => @course.id,
          :format =>'json'

        response.code.should == "401"
      end

      it "should not return any data" do
        get "api/dashboard/teacher_participation",
          :course_id => @course.id,
          :format =>'json'

        ActiveSupport::JSON.decode(response.body).
          should have_key 'error'
      end
    end

    context "GET teacher_participation_interaction" do
      before do
        @environment.courses.reload
        @space = Factory(:space, :owner => @environment.owner,
                         :course => @environment.courses.first)
        @course.spaces.reload
        @params = { :course_id => @course.id,
                    :teacher_id => @course.teachers.first.id,
                    :date_start => "2012-03-01",
                    :date_end => "2012-03-10",
                    :spaces => [@space.id.to_s],
                    :format => :json}
      end

      it "should return 401 (unauthorized) HTTP code" do
        get "api/dashboard/teacher_participation_interaction",
          @params

        response.code.should == "401"
      end

      it "should not return any data" do
        get "api/dashboard/teacher_participation_interaction",
          @params

        ActiveSupport::JSON.decode(response.body).
          should have_key 'error'
      end
    end
  end
end
