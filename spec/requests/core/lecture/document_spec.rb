require 'request_spec_helper'

describe 'Document' do
  before do
    @professor = Factory(:user)
    @course = Factory(:course, :plan => Factory(:plan), :owner => @professor,
                      :environment => Factory(:environment, :owner => @professor))
    @space = Factory(:space, :course => @course)
    @subject = Factory(:subject, :space => @space, :finalized => true)
    login_as @professor
  end

  context 'Creation' do

    context 'when filling the form properly' do
      after do
        File.open(@file, 'w')

        visit edit_space_subject_path(@space, @subject)
        click_link 'Documento e apresentação'
        fill_in 'lecture_name', :with => @file.humanize
        attach_file 'Arquivo', "#{@file}"
        click_button 'Adicionar'
        within('#resources_list') do
          page.should have_content @file.humanize
        end
        File.delete @file
        File.delete "public/images/documents/attachments/#{@subject.id}/original/#{@file}"
      end

      it 'allows the creation of lecture with a pdf document upload', :js => true do
        @file = 'notas_aulas.pdf'
      end

      it 'allows the creation of lecture with a doc document upload', :js => true do
        @file = 'text_book.doc'
      end

      it 'allows the creation of lecture with a ppt document upload', :js => true do
        @file = 'introductory_presentation.ppt'
      end
    end # context 'when filling the form properly'

    context 'when not filling the form properly' do
      it 'shows validation error message if neither file name is filled or file is attached', 
         :js => true do
        visit edit_space_subject_path(@space, @subject)
        click_link 'Documento e apresentação'
        click_button 'Adicionar'
        assert_validation_error_message_is_shown 'não pode ser deixado em branco'
      end

      it 'shows validation error message if file name isn\'t filled', :js => true do
        @file = 'aula_apresentacao.ppt'
        File.open(@file, 'w')
        visit edit_space_subject_path(@space, @subject)
        click_link 'Documento e apresentação'
        attach_file 'Arquivo', "#{@file}"
        click_button 'Adicionar'
        assert_validation_error_message_is_shown 'não pode ser deixado em branco'
        File.delete @file
      end

      it 'shows validation error message if file isn\'t attached', :js => true do
        visit edit_space_subject_path(@space, @subject)
        click_link 'Documento e apresentação'
        fill_in 'lecture_name', :with => 'Notas de Aulas'
        click_button 'Adicionar'
        assert_validation_error_message_is_shown 'não pode ser deixado em branco'
      end

      it 'shows validation error message if attached file is not valid', :js => true do
        @file = 'diagrama.png'
        File.open(@file, 'w')
        visit edit_space_subject_path(@space, @subject)
        click_link 'Documento e apresentação'
        fill_in 'lecture_name', :with => @file.humanize
        attach_file 'Arquivo', "#{@file}"
        click_button 'Adicionar'
        assert_validation_error_message_is_shown 'arquivo inválido'
        File.delete @file
      end
    end # context 'when not filling the form properly'
  end # context 'Creation'

  private

  def assert_validation_error_message_is_shown(msg)
    within '.errors_on_field' do
      page.should have_content msg
    end
  end
end
