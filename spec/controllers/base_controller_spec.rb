require 'spec_helper'

describe BaseController do
  describe "GET site_index" do
    context 'when there is not a signed in user' do
      context 'and any additional param' do
        before  do
          get :site_index, :locale => 'pt-BR'
        end

        it 'should assign @user_session' do
          assigns[:user_session].should_not be_nil
        end

        it 'should assign @user' do
          assigns[:user].should_not be_nil
          assigns[:user].should be_a User
        end
      end
    end

    context 'when there is a signed in user' do
      let(:user) { Factory(:user) }

      before do
        login_as user
        get :site_index, :locale => 'pt-BR'
      end

       it { should redirect_to home_user_path(user)}
    end
  end
end
