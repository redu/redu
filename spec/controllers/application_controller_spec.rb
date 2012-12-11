require 'spec_helper'

describe ApplicationController do
  describe 'Check tour exploration' do
    controller do
      def show
        render :text => "show called"
      end
    end

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
end
