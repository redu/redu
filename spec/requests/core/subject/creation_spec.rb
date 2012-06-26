require 'request_spec_helper'

describe Subject do
  let(:user) { Factory(:user) }

  context 'Creation', :js => true do
    let(:course) { Factory(:course, :plan => Factory(:plan)) }
    let(:space) { Factory(:space, :course => course) }

    before do
      space.course.join user, Role[:teacher]
      login_as(user)

      visit new_space_subject_path(space)
    end

    it 'shows validation errors when does not fill necessary fields' do
        click_on 'Adicionar aulas'

        within '.error_explanation' do
          page.should have_content 'Há problemas para o(s) seguinte(s) campo(s)'
          page.should have_content 'Nome'
        end
    end

    it 'creates a subject with name and descrip., and without lectures' do
      subject_name = 'Introdução'
      fill_in 'Nome', :with => subject_name
      fill_in 'Descrição', :with => 'Lorem ipsum dolor sit amet.'
      click_on 'Adicionar aulas'

      click_on 'Finalizar módulo'

      within '#space-subjects' do
        page.should have_content subject_name
      end
    end
  end
end
