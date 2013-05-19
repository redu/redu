require 'api_spec_helper'

describe "Folders API" do
  let(:environment) { Factory(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:token) { _, _, token = generate_token(course.owner); token }
  let(:params) { { :oauth_token => token, :format => 'json' } }

  context "when is the space's root folder" do
    subject { Factory(:root_folder, :space => space) }

    context "when GET /api/folders/:id" do
      before do
        get "/api/folders/#{subject.id}", params
      end

      it "should not have property date_modified" do
        parse(response.body).should_not have_key "date_modified"
      end

      %w(folder user).each do |link|
        it "should not have link #{link}" do
          href_to(link, parse(response.body)).should be_blank
        end
      end
    end
  end

  context "when is a common folder" do
    subject { Factory(:complete_folder, :space => space) }

    context "when GET /api/folders/:id" do
      before do
        get "/api/folders/#{subject.id}", params
      end

      it "should return code 200" do
        response.code.should == "200"
      end

      %w(name date_modified id).each do |property|
        it "should have property #{property}" do
          parse(response.body).should have_key property
        end
      end

      %w(self folder files folders space user).each do |link|
        it "should have the link #{link}" do
          href_to(link, parse(response.body)).should_not be_blank
        end
      end

      it "should return the correct folder" do
        parse(response.body)["name"].should == subject.name
      end
    end

    context "when GET /api/folders/:folder_id/folders" do
      let!(:folders) do
        (1..4).collect { Factory(:folder, :parent => subject) }
      end

      before do
        get "/api/folders/#{subject.id}/folders", params
      end

      it "should return code 200" do
        response.code.should == "200"
      end

      it "should return a list of resources" do
        parse(response.body).should be_a Array
      end

      it "should return all folder's folders" do
        parse(response.body).collect { |f| f["name"] }.should ==
          folders.collect(&:name)
      end
    end

    context "when GET /api/spaces/:space_id/folders" do
      let!(:folders) do
        (1..4).collect { Factory(:folder, :space => space) }
      end

      before do
        get "/api/spaces/#{space.id}/folders", params
      end

      it "should return code 200" do
        response.code.should == "200"
      end

      it "should return a list of resources" do
        parse(response.body).should be_a Array
      end

      it "should return only space's root folder" do
        parse(response.body).collect { |f| f["name"] }.should ==
          [space.root_folder.name]
      end
    end
  end

  context "when POST /api/folders/:id/folder" do
    let(:root) { space.root_folder }

    context "without validation error" do
      let(:folder_params) do
        { :folder => { :name => "Guila's folder" } }
      end
      before do
        post "/api/folders/#{root.id}/folders", params.merge(folder_params)
      end

      it "should return code 201" do
        response.code.should == "201"
      end

      it "should have the correct name" do
        parse(response.body)["name"].should == folder_params[:folder][:name]
      end
    end

    context "with validation error" do
      let(:folder_params) do
        { :folder => { :name => nil } }
      end
      before do
        post "/api/folders/#{root.id}/folders", params.merge(folder_params)
      end

      it "should return 422" do
        response.code.should == "422"
      end

      it "should return validation error" do
        response.body.should =~ /name/
      end
    end
  end

  context "when PUT /api/folders/:id" do
    subject do
      Factory(:complete_folder, :space => space, :parent => space.root_folder)
    end

    it "should return code 204" do
      put "/api/folders/#{subject.id}", params.
        merge({ :folder => { :name => 'Foobar' } })
      response.code.should == "204"
    end

    context "with validation error" do
      before do
        put "/api/folders/#{subject.id}", params.
          merge({ :folder => { :name => nil } })
      end

      it "should return 422 code" do
        response.code.should == "422"
      end

      it "should include the validation error" do
        response.body.should =~ /name/
      end
    end
  end

  context "DELETE /api/files/:id" do
    subject do
      Factory(:complete_folder, :space => space, :parent => space.root_folder)
    end

    it "should return 204" do
      delete "/api/folders/#{subject.id}", params
      response.code.should == "204"
    end
  end
end
