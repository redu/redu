require "api_spec_helper"

describe "User" do
  context "when GET /user/:id" do
    before do
      @user = Factory(:user, :mobile => "+55 (81) 9194-5317",
                      :localization => "Recife", :birth_localization => "Recife")
      get "/api/users/#{@user.id}", :format => 'json'

      @application, @current_user, @token = generate_token
    end

    it "should return status 200 (ok)" do
      response.code.should == "200"
    end

    it "should have login, id, links, email, first_name, last_name, birthday, friends_count, mobile, localization, birth_localization" do

      %w(login id links email first_name last_name birthday friends_count mobile localization birth_localization).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should link to itself" do
      link = parse(response.body)['links'].detect { |l| l['rel'] == 'self' }

      get link['href'], :format => 'json'
      response.code.should == '200'
    end

    it "should link to enrollments" do
      link = parse(response.body)['links'].detect { |l| l['rel'] == 'enrollments' }

      link.should_not be_nil
    end
  end

  context "when GET /space/:space_id/users" do
    before do
      @environment = Factory(:complete_environment)
      @course = @environment.courses.first
      @space = @course.spaces.first

      @members = 3.times.collect do
        user = Factory(:user)
        @course.join(user)
        user
      end
      @members << @course.owner
    end

    it "should return 200" do
      get "/api/spaces/#{@space.id}/users", :oauth_token => @token,
        :format => 'json'

      response.code.should == '200'
    end

    it "should return the correct number of users" do
      get "/api/spaces/#{@space.id}/users", :oauth_token => @token,
        :format => 'json'

      parse(response.body).length.should == @members.length
    end

    it "should return the correct members" do
      get "/api/spaces/#{@space.id}/users", :oauth_token => @token,
        :format => 'json'

      parse(response.body).collect { |m| m['id'] }.to_set.should ==
        @members.collect(&:id).to_set
    end

    it "should filter by members" do
      get "/api/spaces/#{@space.id}/users", :role => 'member',
        :oauth_token => @token, :format => 'json'

      parse(response.body).length.should == @members.length - 1
    end

    it "should filter by members" do
      get "/api/spaces/#{@space.id}/users", :role => 'member',
        :oauth_token => @token, :format => 'json'

      parse(response.body).length.should == @members.length - 1
    end
  end

  context "when GET /space/:space_id/user to a non-existent space" do
    it "should return code 404 (not existent)" do
      get "/api/spaces/2198219/users", :oauth_token => @token,
        :format => 'json'

      response.code.should == '404'
    end
  end
end
