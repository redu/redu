require 'request_spec_helper'

describe "Hierarchy" do
    let(:user) { Factory(:user) }

  describe "Creation" do
    before do
      login_as(user)
    end

    it "creates an environment plus course, space and empty subject", :js => true do
        environment_name = 'Universidade de Pernambuco'
        course_name = 'Administração'
        # Criação de ambiente + curso
        click_on 'Ensine'

        fill_in 'Seu ambiente de ensino', :with => environment_name
        fill_in 'Seu primeiro curso', :with => course_name
        click_on 'Avançar'

        within '.best-choice' do
          click_on 'Assinar'
        end

        fill_in 'Abreviação', :with => 'UPE'
        click_on 'Assinar'

        click_on 'Finalizar'
        Capybara.default_wait_time = 3
        page.should have_button 'Pagar'

        click_on 'Início'
        click_on environment_name
        page.should have_content environment_name
        within '.big-tabs' do
          page.should have_content course_name
        end

        # Criação de disciplina
        space_name = 'Contabilidade'
        click_on course_name
        click_on 'Criar nova disciplina'

        fill_in 'Nome', :with => space_name
        fill_in 'Descrição', :with => 'Lorem ipsum dolor sit amet,' \
        ' consectetur adipisicing elit, sed do eiusmod tempor incididunt'
        fill_in 'Palavras-chaves', :with => 'tag, legal'
        click_on 'Criar disciplina'

        page.should have_content environment_name
        page.should have_content course_name
        within '.big-tabs' do
          page.should have_content space_name
        end

        # Criação de módulo sem aulas
        click_on space_name
        subject_name = 'Conceitos Básicos'
        click_on 'Criar novo módulo'

        fill_in 'Nome', :with => subject_name
        fill_in 'Descrição', :with => 'Lorem ipsum dolor sit amet,' \
        ' consectetur adipisicing elit, sed do eiusmod tempor incididunt'
        choose 'subject_visible_true'
        click_on 'Adicionar aulas'

        click_on 'Finalizar módulo'

        within '#space-subjects' do
          page.should have_content subject_name
        end
      end
  end
end
