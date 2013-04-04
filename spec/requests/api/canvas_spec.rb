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
    it_should_behave_like "a lecture created" do
      let(:mimetype) { 'application/x-canvas' }
      let(:url) { "/api/subjects/#{sub.id}/lectures"  }
      let(:lecture_params) do
        { :lecture => \
          { :name => 'Lorem', :type => 'Canvas', :current_url => "http://foo.bar.com" }
        }.merge(base_params)
      end
    end

    it_should_behave_like "a canvas"

    context "with validation error" do
      before do
        canvas_params[:lecture][:current_url] = "not a URL"
        post "api/spaces/#{space.id}/canvas", canvas_params
      end

      it "should return the 422 HTTP code" do
        response.code.should == "422"
      end
    end
  end

  context "GET /api/spaces/:space_id/canvas" do
    it "should return the correct canvas representations" do
      canvas = 3.times.collect do
        Factory(:canvas, :container => space, :user => space.owner)
      end

      get "api/spaces/#{space.id}/canvas", params

      parse(response.body).collect { |r| r["id"] }.
        to_set.should == canvas.collect(&:id).to_set
    end
  end
end
