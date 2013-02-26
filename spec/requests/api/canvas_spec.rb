require 'api_spec_helper'

describe "Canvas API" do
  let(:environment) { Factory(:complete_environment) }
  let(:course) { environment.courses.first }
  let(:space) { course.spaces.first }
  let(:subj) { Factory(:subject, :owner => course.owner,
                          :space => space, :finalized => true) }
  let(:token) { _, _, token = generate_token(course.owner); token }
  let(:base_params) { { :oauth_token => token, :format => 'json' } }

  context "when POST /subjects/:subject_id/lectures" do
    context "when creating canvas" do
      context "when the params is correct" do
        let(:params) do
          base_params.merge({:lecture => {
            :name => "My Goku Lecture",
            :type => "Canvas",
            :position => 1,
          }})
        end

        it "should return code 201 (created)" do
          post "api/subjects/#{subj.id}/lectures", params
          response.code.should == '201'
        end

        it "should return the entity" do
          post "api/subjects/#{subj.id}/lectures", params
          parse(response.body)['name'].should == params[:lecture][:name]
        end
      end

      context "when the params aren't correct" do
        let(:params) { base_params.merge({ :lecture => { :name => "" } }) }

        it "should return code 422 when not valid" do
          post "api/subjects/#{subj.id}/lectures", params
          response.code.should == '422'
        end

        it "should return the error explanation" do
          post "api/subjects/#{subj.id}/lectures", params
          parse(response.body).should have_key "name"
        end
      end
    end

    context "when creating canvas with URL" do
      context "when the params are correct" do
        let(:params) do
          base_params.merge({:lecture => {
            :name => "My Goku Lecture",
            :type => "Canvas",
            :current_url => "http://google.com.br",
          }})
        end

        it "should return code 201 (created)" do
          post "api/subjects/#{subj.id}/lectures", params
          response.code.should == '201'
        end

        it "should return the entity" do
          post "api/subjects/#{subj.id}/lectures", params
          parse(response.body)["current_url"].should ==
              params[:lecture][:current_url]
        end
      end

      context "when the params are incorrect" do
        let(:params) do
          base_params.merge({:lecture => {
            :name => "My Goku Lecture",
            :type => "Canvas",
            :current_url => "google.com.br",
          }})
        end

        it "should return code 422" do
          post "api/subjects/#{subj.id}/lectures", params
          response.code.should == '422'
        end

        it "should return the error explanation" do
          post "api/subjects/#{subj.id}/lectures", params
          parse(response.body).values.flatten.should include "não é uma URL"
        end
      end
    end
  end

  context "when GET /lectures/:id" do
    subject do
      Factory(:lecture, :lectureable => Factory(:canvas),
              :subject => subj, :owner => subj.owner)
    end

    before do
      get "/api/lectures/#{subject.id}", base_params
    end

    it_should_behave_like "a lecture"

    %w(mimetype current_url).each do |attr|
      it "should have property #{attr}" do
        parse(response.body).should have_key attr
      end
    end

     it "should have the link raw" do
       href_to("raw", parse(response.body)).should_not be_blank
     end
  end
end
