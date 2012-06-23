require 'request_spec_helper'

describe Course do
  let(:user) { Factory(:user) }

  describe "Creation" do
    let(:environment) { Factory(:environment, :owner => user) }

    before do
      login_as(user)
    end

    context "through environment admin panel" do
      # Vai para o painel de gerenciamento do ambiente (aba cursos)
      before do
        visit environment_path(environment)
        click_on 'Gerenciar ambiente'

        within '.tabs' do
          click_on 'Cursos'
        end
        click_on 'Criar novo curso'
      end

      # Tenta criar um curso sem preencher campos obrigatórios
      it "show validation errors" do
        fill_in 'Palavras-chave', :with => 'tag, legal'
        click_on 'Salvar alterações'

        within '.error_explanation' do
          page.should have_content 'Há problemas para o(s) seguinte(s) campo(s)'
          page.should have_content 'Nome, Endereço'
        end
      end

      # Cria um curso ao preencher todos os campos obrigatórios
      it "creates a course with name, descrip. and tags", :js => true do
        fill_in 'Nome', :with => 'Serviço Social'
        fill_in 'Descrição',
          :with => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.'
        fill_in 'Palavras-chave', :with => 'tag, legal'

        click_on 'Salvar alterações'

        current_path.should == environment_course_path(environment, Course.last)
        page.should have_content environment.name
        page.should have_content 'Serviço Social'
        page.should have_content 'Lorem ipsum dolor sit amet, consectetur' \
          ' adipisicing elit.'
        page.should have_content 'tag'
        page.should have_content 'legal'
      end
    end
  end
end
