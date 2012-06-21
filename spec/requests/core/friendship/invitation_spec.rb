require 'request_spec_helper'

def invite_friend_registred_by_email(user)
  invite_friend(user.email)
  within '.friendship-dropdown' do
    all('li').each { |li| li.click if li.text == user.display_name }
  end
end

def invite_friend_by_email(param)
  if param.is_a? User
    invite_friend(param.display_name)
    within '.friendship-dropdown' do
      all('li').each { |li| li.click if li.text == param.display_name }
    end
  else
    invite_friend(param)
    find('#invite_email').click
  end
end

def invite_friend_by_login(user)
  invite_friend(user.login)
  within '.friendship-dropdown' do
    all('li').each do |li|
      li.click if li.text == user.display_name
    end
  end
end

def invite_friend_by_name(user)
  invite_friend(user.display_name)
  within '.friendship-dropdown' do
    all('li').each do |li|
      li.click if li.text == user.display_name
    end
  end
end

private
def invite_friend(key)
  find('form#invite-members ul li input[autocomplete=off]').set(key)
  sleep 3
end

describe "MailInvitation" do
  let(:batman) { Factory(:user, :login => 'batman',
                         :first_name => 'Bruce',
                         :last_name => 'Wayne',
                         :email => 'contact@wayne.org') }

  let(:superman) { Factory(:user, :login => 'superman',
                           :first_name => 'Clark',
                           :last_name => 'Kent',
                           :email => 'kent@dailyplanet.com') }

  let(:wonder_woman) { Factory(:user, :login => 'wonder_woman',
                               :first_name =>'Diana',
                               :last_name => 'Prince',
                               :email => 'diana@redu.com.br')}

  let(:flash) { Factory(:user, :login => 'flash',
                        :first_name =>'Barry',
                        :last_name => 'Allen',
                        :email => 'barry@redu.com.br')}

  before do
    login_as(batman)
  end

  it "should access friendship invitation view through home" do
    current_path.should == home_user_path(batman)
    page.find('.secondary-sidebar.home-sidebar').should have_content 'Convide ou procure seus amigos'
    click_on 'Convide ou procure seus amigos'
    sleep 2
    current_path.should == new_user_friendship_path(batman)
  end

  context 'when user input is in invalid or blank' do
    before do
      visit new_user_friendship_path(batman)
      sleep 2
      current_path.should == new_user_friendship_path(batman)
    end

    it "> invalid name or email should generate the error message: 'Nenhum convite para ser enviado.'", :js => true do
      page.find('form#invite-members ul li input[autocomplete=off]').set('invalid_text')
      find('#admin-invitations').click # Tive de fazer isso já que a mensagem impede o click no botão
      click_on 'Enviar convite'
      sleep 2
      page.should have_content 'Nenhum convite para ser enviado.'
    end

    it "> blank submission should generate the error message: 'Nenhum convite para ser enviado.'", :js => true do
      page.find('form#invite-members ul li input[autocomplete=off]').text.should be_empty
      click_on 'Enviar convite'
      sleep 2
      page.should have_content 'Nenhum convite para ser enviado.'
    end
  end

  describe 'Name based invitation' do
    before do
      visit new_user_friendship_path(batman)
      sleep 1
      current_path.should == new_user_friendship_path(batman)
    end

    it "when input user login, name or email(if registred), a dropdown list should appear and user should able to add in invitation list", :js => true do
      [superman, wonder_woman, flash].each do |hero|
        if hero == superman
          invite_friend_by_login(hero)
        elsif hero == wonder_woman
          invite_friend_by_name(hero)
        else
          invite_friend_registred_by_email(hero)
        end

        find('.token-input-list').should have_content hero.display_name
        click_on 'Enviar convites'
        sleep 3
        page.should have_content 'Convites enviados com sucesso.'
        invitations = find('.concave-invitation-table')
        invitations.should have_link hero.display_name
        invitations.should have_link 'Reenviar convite'
        invitations.should have_content 'O usuário ainda não aceitou o convite de amizade.'
      end
    end
  end

  describe 'Mail invitation' do
    context 'when an email already exists at Redu' do
    end
  end

  context 'when invite many users at the same time' do
    before do
      visit new_user_friendship_path(batman)
      sleep 1
      current_path.should == new_user_friendship_path(batman)
    end

    it "should recive sucess message 'Convites enviados com sucesso.'", :js => true do
      justice_league = [superman,'ajax@redu.com.br' ,wonder_woman, 'thor@asgard.br', 'hall_jordam@redu.com.br']
      justice_league.each do |hero|
        invite_friend_by_email(hero)
        if(hero.is_a? User)
          find('.token-input-list').should have_content hero.display_name
        else
          find('.token-input-list').should have_content hero
        end
      end

      # Remove o Thor (DC Rulez)
      within '.token-input-list' do
        all('li').each do |li|
          if li.has_content? 'thor@asgard.br'
            li.find('.token-input-delete-token-email').click
          end
        end
      end

      click_on 'Enviar convites'
      sleep 3
      page.should have_content 'Convites enviados com sucesso.'
      invitations = find('.concave-invitation-table')

      (justice_league-['thor@asgard.br']).each do |hero|
        if hero.is_a? User
          invitations.should have_link hero.display_name
        else
          invitations.should have_content hero
        end
        invitations.should have_link 'Reenviar convite'
        invitations.should have_content 'O usuário ainda não aceitou o convite de amizade.'
      end
    end
  end
end
