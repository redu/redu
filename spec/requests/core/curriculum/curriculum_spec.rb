require 'request_spec_helper'

def change_select(type)
  page.select type, :from => "education_type"
end

def another_education
  find('.new-education-button').click
end

describe "Curriculum" do
  let(:user) { Factory(:user) }

  before do
    login_as (user)
  end

  context "visiting curriculum page" do
    it "through config link" do
      click_link 'Configurações'
      click_link 'Currículo'
      current_path.should eq(curriculum_user_path(user))
    end

    context "through nav account" do
      let(:nav) { "#nav-account" }

      it "config link" do
        find(nav).click_link 'Configurações'
        click_link 'Currículo'
        current_path.should eq(curriculum_user_path(user))
      end

      it "edit link" do
        find(nav).click_link 'editar'
        click_link 'Currículo'
        current_path.should eq(curriculum_user_path(user))
      end

      it "profile link" do
        find(nav).click_link 'Meu Perfil'
        click_link 'Editar'
        click_link 'Currículo'
        current_path.should eq(curriculum_user_path(user))
      end
    end
  end

  context "creating", :js => true do
    before do
      visit curriculum_user_path(user)
    end

    it "complet curriculum" do
      find("#experience_title").set("Vendedor de peixe")
      find("#experience_company").set("Cais do Apolo")
      find("#experience_description").set("Sem carteira assinada")
      find("#experience_submit").click

      page.should have_content("Vendedor de peixe em Cais do Apolo")
      page.should have_content("Sem carteira assinada")

      find("#high_school_institution").set("Damas")
      page.select '2007', :from => 'high_school_end_year_1i'
      find("#high_school_submit").click

      page.should have_content("Ensino Médio em Damas")
      page.should have_content("2007")

      another_education
      change_select("Ensino Superior")
      page.select "Bacharelado", :from => "higher_education_kind"
      find("#higher_education_institution").set("Farec")
      find("#higher_education_course").set("Administração")
      find('#higher_education_description').set("3 anos de graduação")
      find("#higher_education_submit").click

      page.should have_content("Bacharelado em Administração pela Farec")
      page.should have_content("3 anos de graduação")

      another_education
      change_select("Ensino Superior")
      page.select "Doutorado", :from => "higher_education_kind"
      find("#higher_education_institution").set("UVA")
      find("#higher_education_research_area").set("Contabilidade")
      page.select '2008', :from => 'higher_education_start_year_1i'
      find("#higher_education_submit").click

      page.should have_content("Doutorado em Contabilidade pela UVA")
      page.should have_content("2008")

      find('.new-experience-button').click
      find("#experience_title").set("Gerente")
      find("#experience_company").set("Empresa São Paulo")
      page.select 'Fevereiro', :from => 'experience_start_date_2i'
      find("#experience_submit").click

      page.should have_content("Gerente em Empresa São Paulo")
      page.should have_content("February")

      another_education
      change_select("Curso Complementar")
      find("#complementary_course_course").set("Fotografia")
      find("#complementary_course_institution").set("Senac")
      find("#complementary_course_workload").set(180)
      find("#complementary_course_submit").click

      page.should have_content("Fotografia pela Senac")
      page.should have_content("180 horas")

      another_education
      change_select("Evento")
      find("#event_education_name").set("Campus Party")
      page.select '2011', :from => 'event_education_year_1i'
      page.select 'Palestrante', :from => 'event_education_role'
      find("#event_education_submit").click

      page.should have_content("2011")
      page.should have_content("Campus Party, palestrante")
    end
  end
end
