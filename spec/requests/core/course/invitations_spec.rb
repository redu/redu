require 'request_spec_helper'

describe 'CourseInvitations' do

  before do
    @joao = Factory(:user, :login => 'joaoo', :email => 'joaoo@example.com')
    @course = Factory(:course, :environment => Factory(:environment, :plan => Factory(:plan)))
    @course.join @joao
    login_as(@joao)
  end

  # Este teste assegura que o usuário pode chegar (e como ele chega) até a página
  # de convite de usuários para curso. Outros testes já se iniciam dessa página.
  it "ensures that invitation page is reachable" do
    visit application_path
    within('.local-nav') do
      click_link @course.environment.name
    end
    click_link @course.name
    # como João não é administrador, ele vê somente a opção de sair do curso
    page.should have_content "Abandonar curso"
  end

  it "does not allow non administrators users invite other users" do
    visit environment_course_path(@course.environment, @course)
    page.should_not have_content("Convidar membros")
  end

  context "when current user is the course administrator" do
    before do
      # transforma João em administrador
      @course.change_role @joao, Role[:environment_admin]
      visit admin_invitations_environment_course_path(@course.environment, @course)
    end

    it "he can invite other users with their e-mail", :js => true do
      fill_in_email_or_username 'maria@foo.com'
      click_link 'invite_email'
      fill_in_email_or_username 'jose@bar.com'
      click_link 'invite_email'
      click_button 'Enviar convites'
      page.should have_content(success_message)
    end

    it "he can invite registered users with their names", :js => true do
      fred = Factory(:user, :first_name => 'Fred', :last_name => 'Krueger')
      fill_in_email_or_username 'Fred Krueger'
      select_from_helper_list(fred.display_name)
      click_out
      click_button 'Enviar convites'
      page.should have_content(success_message)
    end

    it "he may use the dropdown search box to find and invite users", :js => true do
      mike = Factory(:user, :first_name => 'Michael', :last_name => 'Myers')
      fill_in_email_or_username 'Mic'
      select_from_helper_list(mike.display_name)
      click_out
      click_button 'Enviar convites'
      page.should have_content(success_message)
    end
  end # context "when current user is the course administrator"

  private

  def fill_in_email_or_username(key)
    page.find('form#invite-members ul li input[autocomplete=off]').set(key)
    sleep 2
  end

  def select_from_helper_list(key)
    within '.token-input-dropdown' do
      all('li').each { |li| li.click if li.text == key }
    end
  end

  def click_out
    # Tive de fazer isso já que a mensagem impede o click no botão
    find('#admin-invitations').click
  end

  def success_message
    "convidados via e-mail"
  end
end
