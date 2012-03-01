require "api_spec_helper"

describe "User" do
  context "when GET /user/:id" do
    before do
      @user = Factory(:user, :mobile => "+55 (81) 9194-5317",
                      :localization => "Recife", :birth_localization => "Recife")
      get "/api/users/#{@user.id}", :format => 'json'
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
end
