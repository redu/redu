require "api_spec_helper"

describe "Subjects API" do
  before do
    @application, @current_user, @token = generate_token

    @environment = Factory(:complete_environment, :owner => @current_user)
    @space = @environment.courses.first.spaces.first

    @subject = Subject.create(:title => "Test Subject 1",
                              :description => "Test Subject Description",
                              :space => @space)
    # precisa atualizar manualmente para criar um módulo vazio
    @subject.update_attribute(:finalized, true)

    @params = { :oauth_token => @token, :format => "json" , "subject" => {} }
  end

  context "the document returned" do
    before do
      get "api/subjects/#{@subject.id}", @params
    end

    it "should have the correct keys" do
      %w(id title description created_at links).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should hold the correct relationships"  do
      links = parse(response.body)['links']
      links.collect! { |l| l.fetch('rel') }

      links.should include 'self'
      links.should include 'lectures'
      links.should include 'space'
      links.should include 'course'
      links.should include 'environment'
    end
  end

  context "GET subjects list from a space" do
    context "when the space has subjects" do
      before do
        get "/api/spaces/#{@space.id}/subjects", @params
      end

      it "should return status 200" do
        response.status.should == 200
      end

      it "should return a list of subjects" do
        parse(response.body).should be_kind_of Array
        parse(response.body).first["title"].should == @subject.title
      end
    end

    context "when the space doesn't have subjects" do
      before do
        @subject.destroy
        get "/api/spaces/#{@space.id}/subjects", @params
      end

      it "should return an empty list" do
        parse(response.body).should be_kind_of Array
        parse(response.body).should == []
      end
    end
  end

  context "GET a subject" do

    context "when subject exists" do
      before do
        get "api/subjects/#{@subject.id}", @params
      end

      it "should return status 200" do
        response.status.should == 200
      end
    end

    context "when subject doesn't exist" do
      before do
        @subject.destroy
        get "api/subjects/#{@subject.id}", @params
      end

      it "should return status 404" do
        response.status.should == 404
      end
    end
  end

  context "DELETE a subject" do

    context "when subject exists" do
      before do
        delete "api/subjects/#{@subject.id}", @params
      end

      it "should return status 200" do
        response.status.should == 200
      end
    end

    context "when subject doesn't exist" do
      before do
        @subject.destroy
        delete "api/subjects/#{@subject.id}", @params
      end

      it "should return status 404" do
        response.status.should == 404
      end
    end
  end

  context "POST a subject" do
    before do
      @params["subject"][:title] = "New subject"
      post "/api/spaces/#{@space.id}/subjects", @params
    end

    it "should return code 201" do
      response.code.should == "201"
    end

    it "should return correct number of subjects" do
      get "/api/spaces/#{@space.id}/subjects", @params
      parse(response.body).count.should == @space.subjects.length
    end

    it "should generate status log (user is a member)"

    context "when it's invisible" do
      before do
        @new_course = Factory(:course)
        @new_space = Factory(:space, :course => @new_course)
        @params["subject"][:visible] = false
      end

      it "should return code 201 (invisible)" do
        @new_course.join(@current_user, Role[:environment_admin])
        post "/api/spaces/#{@new_space.id}/subjects", @params
        response.code.should == "201"
      end

      it "should return subject_enrollments list"

      it "should return empty list" do
        @new_course.join(@current_user, Role[:member])
        post "/api/spaces/#{@new_space.id}/subjects", @params

        get "/api/spaces/#{@new_space.id}/subjects", @params
        parse(response.body).should be_empty
      end

      it "should return subject list (not empty)" do
        @new_course.join(@current_user, Role[:teacher])
        post "/api/spaces/#{@new_space.id}/subjects", @params

        get "/api/spaces/#{@new_space.id}/subjects", @params
        parse(response.body).should_not be_empty
      end

      it "should not generate status log (user is a member)"
    end

    context "when it's invalid" do

      it "should return code 404" do
        post "/api/spaces/007/subjects", @params
        response.code.should == "404"
      end

      it "should return code 422" do
        @params["subject"][:title] = ""
        post "/api/spaces/#{@space.id}/subjects", @params
        response.code.should == "422"
      end
    end

  end

end
