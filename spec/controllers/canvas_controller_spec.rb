require 'spec_helper'
require 'authlogic/test_case'

describe CanvasController do
  include Authlogic::TestCase

  describe "GET 'show'" do
    let(:current_user) { Factory(:user) }
    let(:space) do
      environment = Factory(:complete_environment, :owner => current_user)
      environment.courses.first.spaces.first
    end
    let(:canvas) do
      Factory(:canvas, :user => current_user, :container => space)
    end

    before do
      activate_authlogic
      UserSession.create current_user
    end

    it "should authorize request" do
      controller.should_receive 'authorize!'

      get 'show', :id => canvas.id, :space_id => space.id, :locale => 'pt-BR'
    end

    %w(space canvas client_application).each do |entity|
      it "should assing #{entity}" do
        get 'show', :id => canvas.id, :space_id => space.id, :locale => 'pt-BR'

        assigns[entity.to_sym].should_not be_nil
      end
    end

    it "should render correct view" do
      get 'show', :id => canvas.id, :space_id => space.id, :locale => 'pt-BR'

      response.should render_template 'canvas/show'
    end

    context "when not found" do
      it "should redirect to 404" do
        expect {
          get 'show', :id => 123, :space_id => 456, :locale => 'pt-BR'
        }.should raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
