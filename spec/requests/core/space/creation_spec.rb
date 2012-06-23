require 'request_spec_helper'

describe Space do
  let(:user) { Factory(:user) }

  describe "Creation" do
    let(:course) { Factory(:course, :plan => Factory(:plan)) }

    before do
      course.join user
      course.environment.change_role user, Role[:environment_admin]
      login_as(user)
    end

    context "through course admin panel" do
      # Vai para o painel de gerenciamento do curso (aba disciplinas)
      before do
        visit environment_course_path(course.environment, course)
        click_on 'Gerenciar curso'

        within '.tabs' do
          click_on 'Disciplinas'
        end
        click_on 'Criar uma disciplina'
      end

      # Tenta criar uma disciplina sem preencher campos obrigatórios
      it "show validation errors" do
        fill_in 'Palavras-chave', :with => 'tag, legal'
        click_on 'Criar disciplina'

        within '.error_explanation' do
          page.should have_content 'Há problemas para o(s) seguinte(s) campo(s)'
          page.should have_content 'Nome'
        end
      end

      # Cria uma disciplina ao preencher todos os campos obrigatórios
      it "creates a space with name, descrip. and tags" do
        space_name = 'Cálculo I'
        fill_in 'Nome', :with => space_name
        fill_in 'Descrição',
          :with => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.'
        fill_in 'Palavras-chave', :with => 'tag, legal'

        click_on 'Criar disciplina'

        current_path.should == environment_course_path(course.environment, course)
        click_on space_name
        page.should have_content course.environment.name
        page.should have_content course.name
        page.should have_content space_name
        page.should have_content 'Lorem ipsum dolor sit amet, consectetur' \
          ' adipisicing elit.'
        page.should have_content 'tag'
        page.should have_content 'legal'
      end
    end
  end
end
