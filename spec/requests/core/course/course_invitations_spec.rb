require 'request_spec_helper'

describe "CourseInvitations" do

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
      visit environment_course_path(@course.environment, @course)
      click_link "Membros do Curso"
      click_link "Convidar membros"
    end

    it "he can invite other users with their e-mail", :js => true do
      invite_by_email 'maria@foo.com'
      invite_by_email 'jose@bar.com'
      click_button 'Enviar convites'
      page.should have_content(success_message)
    end

    it "he can invite registered users with their names", :js => true do
      fred = Factory(:user, :first_name => 'Fred', :last_name => 'Krueger')
      page.find('form#invite-members ul li input[autocomplete=off]').set(fred.display_name)
      sleep 2
      within '.token-input-dropdown' do
        all('li').each { |li| li.click if li.text == fred.display_name }
      end
      find('#admin-invitations').click # Tive de fazer isso já que a mensagem impede o click no botão
      click_button 'Enviar convites'
      page.should have_content(success_message)
    end

    it "he may use the dropdown search box to find and invite users", :js => true do
      mike = Factory(:user, :first_name => 'Michael', :last_name => 'Myers')
      page.find('form#invite-members ul li input[autocomplete=off]').set(mike.display_name.first(3))
      sleep 2
      within '.token-input-dropdown' do
        all('li').each { |li| li.click if li.text == mike.display_name }
      end
      find('#admin-invitations').click # Tive de fazer isso já que a mensagem impede o click no botão
      click_button 'Enviar convites'
      page.should have_content(success_message)
    end
  end

  private

  def invite_by_email(email)
    page.find('form#invite-members ul li input[autocomplete=off]').set(email)
    sleep 2
    click_link 'invite_email'
  end

  def success_message
    "convidados via e-mail"
  end
end
