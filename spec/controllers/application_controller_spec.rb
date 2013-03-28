require 'spec_helper'

describe ApplicationController do
  controller do
    def show
      render :text => "show called"
    end
  end

  describe 'Check tour exploration' do
    context 'when logged in' do
      let(:user) { Factory(:user) }
      before do
        login_as user
      end

      context 'when accessing some action with exploring_tour true' do
        before do
          get :show, :id => 'anyid', :exploring_tour => "true"
        end

        it 'responds with success' do
          response.should be_success
        end

        it 'keeps track of the visited url' do
          user.settings.visited?(request.path).should be_true
        end
      end

      context 'when accessing some action without exploring_tour params' do
        before do
          get :show, :id => 'anyid'
        end

        it 'responds with success' do
          response.should be_success
        end

        it 'does not keep track of the visited url' do
          user.settings.visited?(request.path).should be_false
        end
      end
    end

    context 'when not logged in' do
      context 'when accessing some action with exploring_tour true' do
        before do
          get :show, :id => 'anyid', :exploring_tour => "true"
        end

        it 'responds with success' do
          response.should be_success
        end

        it 'does not call visit!' do
          UserSetting.any_instance.should_not_receive(:visit!)
          get :show, :id => 'anyid', :exploring_tour => "true"
        end
      end

      context 'when accessing some action without exploring_tour params' do
        before do
          get :show, :id => 'anyid'
        end

        it 'responds with success' do
          response.should be_success
        end

        it 'does not call visit!' do
          UserSetting.any_instance.should_not_receive(:visit!)
          get :show, :id => 'anyid', :exploring_tour => "true"
        end
      end
    end
  end

  describe 'Current ability' do
    context "when logged in" do
      let(:user) { Factory(:user) }
      before do
        login_as user
        get :show, :id => '1'
      end

      it "current_user should be a valid user" do
        controller.send(:current_user).should == user
      end

      it "current_ability should be a valid ability" do
        controller.send(:current_ability).should == user.ability
      end
    end

    context "when not logged in" do
      it { controller.send(:current_user).should be_nil }
      it { controller.send(:current_ability).should be_nil }
    end
  end
end
