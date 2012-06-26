require 'request_spec_helper'

describe 'DocumentLectureCreation' do
  before do
    @professor = Factory(:user)
    @course = Factory(:course, :plan => Factory(:plan), :owner => @professor,
                      :environment => Factory(:environment, :owner => @professor))
    @space = Factory(:space, :course => @course)
    @subject = Factory(:subject, :space => @space, :finalized => true)
    login_as @professor
  end

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
end
