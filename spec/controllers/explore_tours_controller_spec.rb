# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ExploreToursController do
  describe 'POST create' do
    context 'when marking an id as visited' do
      let(:user) { FactoryBot.create(:user) }
      before do
        login_as user
        xhr :post, :create, :id => 'learn-environments',
          :user_id => user.to_param, :locale => 'pt-BR'
      end

      it 'marks this id as visited by user' do
        user.reload
        user.settings.visited?('learn-environments').should be_true
      end
    end
  end
end
