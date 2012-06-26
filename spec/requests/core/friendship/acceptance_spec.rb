require 'request_spec_helper'

describe "Invitations Acceptance" do
  let(:hostable) { Factory(:user) }
  let(:email) { 'invitee@redu.com.br' }

  before do
    @invitation = Factory(:invitation, :hostable => hostable,
                          :user => hostable,
                          :email => email)
  end

  context "when the user already has an account" do
    let(:invitee) { Factory(:user, :email => email) }

    context "when the user are logged" do
      before do
        login_as(invitee)
        visit invitation_path(@invitation)
      end

      it "should redirected to user home with new friendship request" do
        current_path.should == home_user_path(invitee)

        expect {
          page.find('.friends-requisitions')
        }.should_not raise_error(Capybara::ElementNotFound)

        within '.friends-requisitions' do
          page.should have_link hostable.display_name
        end
      end
    end

    context "when the user log-in" do
      before do
        visit invitation_path(@invitation)
      end

      it "should redirected to user home with new friendship request" do
        page.should have_content 'Olá, você foi convidado para participar do Redu.'
        page.should have_link hostable.display_name

        fill_in 'user_session_login', :with => invitee.login
        fill_in 'user_session_password', :with => invitee.password
        click_on 'Entrar'

        current_path.should == home_user_path(invitee)

        expect {
          page.find('.friends-requisitions')
        }.should_not raise_error(Capybara::ElementNotFound)

        within '.friends-requisitions' do
          page.should have_link hostable.display_name
        end
      end
    end
  end

  context "when the user create an account" do

    let(:email) { 'raitoningu@redu.com.br' }

    before do
      visit invitation_path(@invitation)
    end

    it "after create an account, the user should view a new friendship request" do
      page.should have_link 'Que tal se cadastrar?'
      click_on 'Que tal se cadastrar?'
      current_path.should == signup_path

      fill_in 'user_first_name', :with => 'Claire'
      fill_in 'user_last_name', :with => 'Farron'

      fill_in 'user_login', :with => 'raitoningu'
      fill_in 'user_email', :with => email
      fill_in 'user_email_confirmation', :with => email

      fill_in 'user_password', :with => 'qwe12345'
      fill_in 'user_password_confirmation', :with => 'qwe12345'
      check 'user[tos]'

      click_on 'Cadastre'

      page.should have_content "Obrigado pelo cadastro! Você deve receber um e-mail de confirmação em #{email}."
      page.should have_content "Cadastro efetuado!"
      click_on 'Conheça a Home e comece já!'

      user = User.where(:email => email).first
      current_path.should == home_user_path(user)

      expect {
        page.find('.friends-requisitions')
      }.should_not raise_error(Capybara::ElementNotFound)

      within '.friends-requisitions' do
        page.should have_link hostable.display_name
      end
    end
  end
end
