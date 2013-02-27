require  'api_spec_helper'

describe 'Canvas API' do
  let(:environment) { Factory(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:token) { _, _, token = generate_token(space.owner); token }
  let(:params) { { :oauth_token => token, :format => 'json' } }

  subject do
    Factory(:canvas, :container => space, :user => space.owner)
  end

  context "GET /api/canvas/:id" do
    before do
      get "api/canvas/#{subject.id}", params
    end

    it_should_behave_like "a canvas"
  end

  context "POST /api/spaces/:id/canvas" do
    let(:canvas_params) do
      params[:canvas] = {
        :name => "My awesome canvas",
        :current_url => "http://foo.bar.com"
      }
      params
    end
    before do
      post "api/spaces/#{space.id}/canvas", canvas_params
    end

    it "should return the 201 HTTP code" do
      response.code.should == "201"
    end

    it "should create with the name specified" do
      parse(response.body)["name"].should == canvas_params[:canvas][:name]
    end

    it_should_behave_like "a canvas"

    context "with validation error" do
      before do
        canvas_params[:canvas][:current_url] = "not a URL"
        post "api/spaces/#{space.id}/canvas", canvas_params
      end

      it "should return the 422 HTTP code" do
        response.code.should == "422"
      end
    end
  end
end
