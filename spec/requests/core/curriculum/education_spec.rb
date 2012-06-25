require 'request_spec_helper'

def change_select(type)
  page.select type, :from => "education_type"
end

def another_education
  find('.new-education-button').click
end

describe "Education" do
  let(:user) { Factory(:user) }

  let(:edit) { ".edit-education" }
  let(:item) { ".educations li" }

  before do
    login_as(user)
  end

  context "Creating", :js => true do
    before do
      visit curriculum_user_path(user)
    end

    context "new high school" do
      let(:institution_item) { "#high_school_institution" }

      let(:form) { "#new_high_school" }
      let(:button_submit) { "#high_school_submit" }

      let(:create_high_school) {
        find(institution_item).set("CPI")
        find(button_submit).click
      }

      # Validation
      it "can't create an high school without institution" do
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      # Creation
      it "can create an high school" do
        find(institution_item).set("CPI")
        find(button_submit).click

        find(item).should have_content("Ensino Médio em CPI")
      end

      it "can create another high school" do
        create_high_school
        sleep 2

        another_education

        page.should have_css(form, :visible => true)
        find(institution_item).set("Agnes")
        find(button_submit).click

        page.should have_content("Ensino Médio em Agnes")
      end

      # Editing
      it "can edit and save a high school" do
        create_high_school
        sleep 2

        find(item).find(edit).click
        page.should have_css(item, :visible => false)

        page.select '2010', :from => 'high_school_end_year_1i'
        find('#high_school_description').set("Primeiro ano do Ensino Médio")
        find(button_submit).click

        page.should have_content("2010")
        page.should have_content("Primeiro ano do Ensino Médio")
      end
    end

    context "new higher education" do
      let(:institution_item) { "#higher_education_institution" }
      let(:course_item) { "#higher_education_course" }

      let(:form) { "#new_higher_education" }
      let(:button_submit) { "#higher_education_submit" }

      let(:create_higher_education) {
        find(institution_item).set("Unicap")
        find(course_item).set("Medicina")
        find(button_submit).click
      }

      before do
        change_select("Ensino Superior")
      end

      # Validations
      it "can't create higher education without course" do
        find(institution_item).set("Unicap")
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      it "can't create higher education without institution" do
        find(course_item).set("Medicina")
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      # Creation
      it "can create a higher education course" do
        find(institution_item).set("Unicap")
        find(course_item).set("Medicina")
        find(button_submit).click

        page.should have_content("Medicina pela Unicap")
      end

      it "can create another higher education" do
        create_higher_education
        sleep 2

        another_education

        change_select("Ensino Superior")
        find(institution_item).set("Fafire")
        find(course_item).set("Engenharia")
        find(button_submit).click

        page.should have_content("Engenharia pela Fafire")
      end

      context "area" do
        let(:area_item) { "#higher_education_research_area" }

        before do
          page.select "Doutorado", :from => "higher_education_kind"
        end

        # Validations
        it "can't create higher education without area" do
          find(institution_item).set("Unicap")
          find(button_submit).click

          find(form).should have_xpath('div', :class => 'field_with_erros')
        end

        # Creation
        it "can create a higher education area" do
          find(institution_item).set("Unicap")
          find(area_item).set("Pediatria")
          find(button_submit).click

          page.should have_content("Pediatria pela Unicap")
        end
      end

      # Editing
      it "can edit and save a higher education" do
        create_higher_education
        sleep 2

        find(item).find(edit).click
        page.should have_css(item, :visible => false)

        page.select '2008', :from => 'higher_education_start_year_1i'
        find('#higher_education_description').set("Muito difícil")
        find(button_submit).click

        page.should have_content("2008")
        page.should have_content("Muito difícil")
      end
    end

    context "new complementary course" do
      let(:course_item) { "#complementary_course_course" }
      let(:institution_item) { "#complementary_course_institution" }
      let(:worload_item) { "#complementary_course_workload" }

      let(:form) { "#new_complementary_course" }
      let(:button_submit) { "#complementary_course_submit" }

      let(:create_complementary_course) {
        find(course_item).set("Qualificação")
        find(institution_item).set("Senac")
        find(worload_item).set("20")
        find(button_submit).click
      }

      before do
        change_select("Curso Complementar")
      end

      # Validations
      it "can't create a complementary course without course" do
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      it "can't create a complementary course without institution" do
        find(course_item).set("Qualificação")
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      it "can't create a complementary course without workload" do
        find(course_item).set("Qualificação")
        find(institution_item).set("Senac")
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      # Creation
      it "can create a complementary course" do
        find(course_item).set("Qualificação")
        find(institution_item).set("Senac")
        find(worload_item).set("20")
        find(button_submit).click

        page.should have_content("Qualificação pela Senac")
        page.should have_content("20 horas")
      end

      it "can create another complementary course" do
        create_complementary_course
        sleep 2

        another_education

        change_select("Curso Complementar")
        find(course_item).set("Curso Técnico")
        find(institution_item).set("Senai")
        find(worload_item).set("50")
        find(button_submit).click

        page.should have_content("Curso Técnico pela Senai")
        page.should have_content("50 horas")
      end

      it "can edit and save a complementary course" do
        create_complementary_course
        sleep 2

        find(item).find(edit).click
        page.should have_css(item, :visible => false)

        page.select '2008', :from => 'complementary_course_year_1i'
        find('#complementary_course_description').set("Qualificada")
        find(button_submit).click

        page.should have_content("2008")
        page.should have_content("Qualificada")
      end
    end

    context "new event" do
      let(:name_item) { "#event_education_name" }

      let(:form) { "#new_event_education" }
      let(:button_submit) { "#event_education_submit" }

      let(:create_event) {
        find(name_item).set("Congresso")
        find(button_submit).click
      }

      before do
        change_select("Evento")
      end

      # Validations
      it "can't create an event without a name" do
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      # Creation
      it "can create an event" do
        find(name_item).set("Congresso")
        find(button_submit).click

        page.should have_content("Congresso, participante")
      end

      it "can create another event" do
        create_event
        sleep 2

        another_education

        change_select("Evento")
        find(name_item).set("Convenção")
        find(button_submit).click

        page.should have_content("Convenção, participante")
      end

      it "can edit and save an event" do
        create_event
        sleep 2

        find(item).find(edit).click
        page.should have_css(item, :visible => false)

        page.select '2007', :from => 'event_education_year_1i'
        page.select 'Palestrante', :from => 'event_education_role'
        find(button_submit).click

        page.should have_content("2007")
        page.should have_content("Congresso, palestrante")
      end
    end
  end

  # Remove
  context "Removing" do
    let(:institution_item) { "#high_school_institution" }
    let(:button_submit) { "#high_school_submit" }

    it "user can remove an education", :js => true do
      visit curriculum_user_path(user)
      find(institution_item).set("CPI")
      find(button_submit).click

      find(item).find('.remove-education').click

      alert = page.driver.browser.switch_to.alert
      alert.accept

      page.should have_css(item, :visible => false)
    end
  end
end
