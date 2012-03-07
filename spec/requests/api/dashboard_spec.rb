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

    it "should return 401 (unauthorized) HTTP code" do
      get "api/dashboard/teacher_participation", :id_course => @course.id,
        :format =>'json'

      response.code.should == 401
    end

    it "should not return any data" do
      get "api/dashboard/teacher_participation", :id_course => @course.id,
        :format =>'json'

      ActiveSupport::JSON.decode(response.body).
        should have_key 'error'
    end
  end
end
