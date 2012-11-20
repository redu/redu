require "api_spec_helper"

describe "Subjects API" do
  before do
    @application, @current_user, @token = generate_token
    @environment = Factory(:complete_environment,
                           :owner => @current_user)
    @space = @environment.courses.first.spaces.first
    @subject = Subject.create(:name => "Test Subject 1",
                              :description => "Test Subject Description",
                              :space => @space)
    @subject.update_attribute(:finalized, true)

    @params = {:oauth_token => @token, :format => "json"}
  end

  context "the document returned" do
    before do
      get "api/subjects/#{@subject.id}", @params
    end

    it "should have the correct keys" do
      %w(id name description created_at updated_at links).each do |attr|
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
        parse(response.body).first["name"].should == @subject.name
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

  context "post /spaces/:space_id/subjects" do
    it "should return code 201 (created)" do
      @params[:subject] = { :name => "My new subject"}
      post "/api/spaces/#{@space.id}/subjects", @params
      response.code.should == "201"
    end

    it "should return subject" do
      @params[:subject] = { :name => "My new subject" }
      post "/api/spaces/#{@space.id}/subjects", @params
      parse(response.body).should have_key('name')
    end

    it "should return code 422 (unproccessable entity) when not valid" do
      @params[:subject] = { :name => "" }
      post "/api/spaces/#{@space.id}/subjects", @params
      response.code.should == "422"
    end

    it "should return the error explanation" do
      @params[:subject] = { :name => "" }
      post "/api/spaces/#{@space.id}/subjects", @params
      parse(response.body).should have_key 'name'
    end
  end

end
