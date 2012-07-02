require 'request_spec_helper'

describe "Walls" do
  let(:ned) { Factory(:user, :first_name => 'Ned', :last_name => 'Stark', :login => 'ned_stark') }
  let(:cercei) { Factory(:user, :first_name => 'Cercei', :last_name => 'Lannister', :login => 'cercei_lannister') }

  before do
    # To view walls
    ned.be_friends_with(cercei)
    cercei.be_friends_with(ned)
  end

  context "when user post on your wall" do
    before do
      login_as(ned)
    end

    it "All users(able to view this status) should view 'comentou no seu próprio mural", :js => true do
      current_path.should == home_user_path(ned)
      within '.inform-my-status' do
        fill_in 'Seu mural', :with => 'Winter is coming'
        click_on 'Postar'
      end
      sleep 3 # Espera 3 segundos
      activity_id = Activity.last.id
      page.should have_content "#{ned.display_name} comentou no seu próprio mural"
      page.should have_css("#status-#{activity_id}")
      visit logout_path
      login_as(cercei)
      page.should have_content "#{ned.display_name} comentou no seu próprio mural"
      visit show_mural_user_path(ned)
      page.should have_css("#status-#{activity_id}")
      page.should have_content "#{ned.display_name} comentou no seu próprio mural"
    end
  end

  context "when an user post on another user wall" do
    before do
      login_as(cercei)
    end

    it "that user should view 'comentou no mural de'", :js => true do
      current_path.should == home_user_path(cercei)
      visit show_mural_user_path(ned)
      current_path.should == show_mural_user_path(ned)
      within '.inform-my-status' do
        fill_in 'Seu mural', :with => 'When you play the game of thrones you win or you die. ;D'
        click_on 'Postar'
      end
      sleep 3 # Espera 3 segundos
      activity = Activity.last
      status = page.find("#status-#{activity.id}")
      status.should have_content "#{activity.user.display_name} comentou no mural de #{activity.statusable.display_name}"
    end
  end
end
