require 'request_spec_helper'

def change_select(type)
  page.select type, :from => "education_type"
end

def another_education
  find('.new-education-button').click
end

describe "Education" do
  let(:user) { Factory(:user) }

  let(:item) { ".educations li" }
  let(:edit) { ".edit-education" }

  before do
    login_as(user)
    visit curriculum_user_path(user)
  end

  context "new", :js => true do
    context "high school" do
      let(:institution_item) { "#high_school_institution" }

      let(:form) { "#new_high_school" }
      let(:button_submit) { "#high_school_submit" }

      let(:create_high_school) {
        find(institution_item).set("CPI")
        find(button_submit).click
      }

      # Validation
      it "can't be created without institution" do
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      # Creation
      it "can be created" do
        find(institution_item).set("CPI")
        find(button_submit).click

        find(item).should have_content("Ensino Médio em CPI")
      end

      # Editing
      it "can be edited and updated" do
        create_high_school

        find(item).find(edit).click
        page.should have_css(item, :visible => false)

        page.select '2010', :from => 'high_school_end_year_1i'
        find('#high_school_description').set("Primeiro ano do Ensino Médio")
        find(button_submit).click

        page.should have_content("2010")
        page.should have_content("Primeiro ano do Ensino Médio")
      end
    end

    context "higher education" do
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
      it "can't be created without course" do
        find(institution_item).set("Unicap")
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      it "can't be created without institution" do
        find(course_item).set("Medicina")
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      # Creation
      it "can be created with course" do
        find(institution_item).set("Unicap")
        find(course_item).set("Medicina")
        find(button_submit).click

        page.should have_content("Medicina pela Unicap")
      end

      context "area" do
        let(:area_item) { "#higher_education_research_area" }

        before do
          page.select "Doutorado", :from => "higher_education_kind"
        end

        # Validations
        it "can't be created without area" do
          find(institution_item).set("Unicap")
          find(button_submit).click

          find(form).should have_xpath('div', :class => 'field_with_erros')
        end

        # Creation
        it "can be created with area" do
          find(institution_item).set("Unicap")
          find(area_item).set("Pediatria")
          find(button_submit).click

          page.should have_content("Pediatria pela Unicap")
        end
      end

      # Editing
      it "can be edited and updated" do
        create_higher_education

        find(item).find(edit).click
        page.should have_css(item, :visible => false)

        page.select '2008', :from => 'higher_education_start_year_1i'
        find('#higher_education_description').set("Muito difícil")
        find(button_submit).click

        page.should have_content("2008")
        page.should have_content("Muito difícil")
      end
    end

    context "complementary course" do
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
      it "can't be created without course" do
        find(institution_item).set("Senac")
        find(worload_item).set("20")
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      it "can't be created without institution" do
        find(course_item).set("Qualificação")
        find(worload_item).set("20")
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      it "can't be created without workload" do
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

      # Editing
      it "can be edited and updated" do
        create_complementary_course

        find(item).find(edit).click
        page.should have_css(item, :visible => false)

        page.select '2008', :from => 'complementary_course_year_1i'
        find('#complementary_course_description').set("Qualificada")
        find(button_submit).click

        page.should have_content("2008")
        page.should have_content("Qualificada")
      end
    end

    context "event" do
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
      it "can't be created without a name" do
        find(button_submit).click

        find(form).should have_xpath('div', :class => 'field_with_erros')
      end

      # Creation
      it "can be created" do
        find(name_item).set("Congresso")
        find(button_submit).click

        page.should have_content("Congresso, participante")
      end

      # Editing
      it "can be edited and updated" do
        create_event

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

    it "an education", :js => true do
      find(institution_item).set("CPI")
      find(button_submit).click

      find(item).find('.remove-education').click

      alert = page.driver.browser.switch_to.alert
      alert.accept

      page.should have_css(item, :visible => false)
    end
  end
end
