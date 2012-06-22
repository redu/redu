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

  before do
    login_as(user)
  end

  context "new experience", :js => true do
    before do
      visit curriculum_user_path(user)
    end

    # Validations
    it "can't create an experience without function" do
      submit

      find('.edit-form').should have_xpath('div', :class => 'field_with_erros')
    end

    it "can't create an experience without a company" do
      find(title_item).set("Desenvolvedor")
      submit

      find('.edit-form').should have_xpath('div', :class => 'field_with_erros')
    end

    it "can't create an experience with date range incorrect" do
      find(title_item).set("Desenvolvedor")
      find(company_item).set("Redu")
      page.select 'Janeiro', :from => 'experience_end_date_2i'
      submit

      find('.edit-form').should have_xpath('div', :class => 'field_with_erros')
    end

    # Creation
    it "can create an experience" do
      find(title_item).set("Desenvolvedor")
      find(company_item).set("Redu")
      submit

      find(item).should have_content("Desenvolvedor em Redu")
    end

    it "can create another experience" do
      create_experience
      sleep 2
      find('.new-experience-button').click

      page.should have_css(".edit-form", :visible => true)
      find(title_item).set("Varredor")
      find(company_item).set("Cais")
      submit

      page.should have_content("Varredor em Cais")
    end
  end

  it "user can remove an experience", :js => true do
    visit curriculum_user_path(user)
    create_experience
    find(item).find('.remove-experience').click

    alert = page.driver.browser.switch_to.alert
    alert.accept

    page.should have_css(item, :visible => false)
  end

  context "Edit an experience", :js => true do
    before do
      visit curriculum_user_path(user)
      create_experience
    end

    it "user can save an edited experience" do
      find(item).find('.edit-experience').click

      page.should have_css(item, :visible => false)
      page.should have_css('.edit-form', :visible => true)

      page.select 'Janeiro', :from => 'experience_start_date_2i'
      find('#experience_description').set("Trabalho atualmente")
      submit

      page.should have_content("January")
      page.should have_content("Trabalho atualmente")
    end
  end
end
