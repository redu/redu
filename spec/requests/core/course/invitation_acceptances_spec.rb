require 'request_spec_helper'

describe 'CourseInvitationAcceptances' do

  before do
    @kenobi = Factory(:user, :login => 'ObiWan', :first_name => 'Obi-Wan',
                      :last_name => 'Kenobi', :email => 'kenobi@masters.jedi.com')
    @anakin = Factory(:user, :login => 'Anakin', :first_name => 'Anakin',
                      :last_name => 'Skywalker', :email =>'anakin@apprentices.jedi.com')
    @course = Factory(:course, :name => 'Jedi101',
                      :environment => Factory(:environment, :name => 'JTraining',
                                              :plan => Factory(:plan), 
                                              :owner => @kenobi))
  end

  context 'when invitation receiver is logged' do
    before do
      @course.invite @anakin
      login_as @anakin
    end

    it 'should show warning in the user\'s home view' do
      page.should have_content 'foi convidado para o curso'
      page.should have_content @course.name
      page.should have_button 'Aceitar'
      page.should have_button 'Recusar'
    end

    it 'should show warning in the course page' do
      visit environment_course_path(@course.environment, @course)
      page.should have_content 'já foi convidado'
    end

    context 'and accepts the invitation' do
      before do
        click_button 'Aceitar'
      end

      it 'should asynchronously hide the invitation warning', :js => true do
        assert_that_element_was_hidden "#requisition-#{(@anakin.get_association_with @course).id}"
      end

      it 'should enroll the receiver' do
        @course.users.should include @anakin
      end
    end
  end

  context 'when invited email is not associated with an account' do
    before do
      @darth = Factory.build(:user, :login => 'DarthV', :first_name => 'Darth',
                             :last_name => 'Vader', :email => 'darth@siths.com')
      @course.invite_by_email @darth.email
      visit environment_course_user_course_invitation_path(@course.environment,
                                                           @course,
                                                           (@course.invited? @darth.email))
    end

    it 'allows the creation of a new one and further the invitation acceptance', 
       :js => true do
      click_link 'Que tal se cadastrar?'
      fill_in 'Nome', :with => @darth.first_name
      fill_in 'Sobrenome', :with => @darth.last_name
      fill_in 'Login', :with => @darth.login
      fill_in 'E-mail', :with => @darth.email
      fill_in 'user_email_confirmation', :with => @darth.email
      fill_in 'Senha', :with => @darth.password
      fill_in 'user_password_confirmation', :with => @darth.password
      check 'user_tos'
      click_button 'Cadastre'
      click_link 'Conheça a Home'
      click_button 'Aceitar'
      @darth = User.find('DarthV')
      assert_that_element_was_hidden("#requisition-#{(@darth.get_association_with @course).id}")
    end

    context 'but the invitation receiver owns an account with another email' do
      it 'allows the login with another account and associates the invitation with it', 
         :js => true do
        fill_in 'user_session_login', :with => @anakin.login
        fill_in 'user_session_password', :with => @anakin.password
        click_button 'Entrar'
        click_button 'Aceitar'
        assert_that_element_was_hidden("#requisition-#{(@anakin.get_association_with @course).id}")
      end
    end
  end

  private

  def assert_that_element_was_hidden(element)
    sleep 2
    find(element).visible?.should be_false
  end

end
