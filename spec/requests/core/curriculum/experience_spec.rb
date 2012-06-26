require 'request_spec_helper'

def submit
  find('#experience_submit').click
end

def create_experience
  find('#experience_title').set("Desenvolvedor")
  find('#experience_company').set("Redu")
  submit
end

describe "Experience" do
  let(:user) { Factory(:user) }

  let(:item) { ".experiences li" }

  let(:title_item) { "#experience_title" }
  let(:company_item) { "#experience_company" }

  let(:form) { "#new_experience" }

  before do
    login_as(user)
  end

  context "new experience", :js => true do
    before do
      visit curriculum_user_path(user)
    end

    # Validations
    it "can't be created without function" do
      find(company_item).set("Redu")
      submit

      find(form).should have_xpath('div', :class => 'field_with_erros')
    end

    it "can't be created without company" do
      find(title_item).set("Desenvolvedor")
      submit

      find(form).should have_xpath('div', :class => 'field_with_erros')
    end

    it "can't be create with incorrect date range" do
      find(title_item).set("Desenvolvedor")
      find(company_item).set("Redu")
      page.select 'Janeiro', :from => 'experience_end_date_2i'
      submit

      find(form).should have_xpath('div', :class => 'field_with_erros')
    end

    # Creation
    it "can be created" do
      find(title_item).set("Desenvolvedor")
      find(company_item).set("Redu")
      submit

      find(item).should have_content("Desenvolvedor em Redu")
    end
  end

  it "can be removed", :js => true do
    visit curriculum_user_path(user)
    create_experience
    find(item).find('.remove-experience').click

    alert = page.driver.browser.switch_to.alert
    alert.accept

    page.should have_css(item, :visible => false)
  end

  context "edit", :js => true do
    before do
      visit curriculum_user_path(user)
      create_experience
    end

    it "experience can be updated" do
      find(item).find('.edit-experience').click

      page.should have_css(item, :visible => false)
      page.should have_css('.edit-experience', :visible => true)

      page.select 'Janeiro', :from => 'experience_start_date_2i'
      find('#experience_description').set("Trabalho atualmente")
      submit

      page.should have_content("January")
      page.should have_content("Trabalho atualmente")
    end
  end
end
