require 'request_spec_helper'

describe Seminar do
  let(:user) { Factory(:user) }
  let(:course) { Factory(:course, :plan => Factory(:plan)) }
  let(:space) { Factory(:space, :course => course) }
  let(:subj) { Factory(:subject, :space => space, :finalized => true) }

  before do
    course.join user, Role[:teacher]
    login_as(user)
  end

  context 'Creation', :js => true do
    before do
      visit edit_space_subject_path(space, subj)
      click_on 'Vídeo'
      sleep 2
    end

    context 'Youtube' do
      before do
        choose 'Youtube'
      end

      context 'when not filling the form properly' do
        it 'show validation errors' do
          click_on 'Adicionar'

          page.should have_content 'não pode ser deixado em branco'
          page.should have_css 'ul.errors_on_field > li', :count => 2
        end
      end

      context 'when filling the form only with the url' do
        let(:youtube_name) { 'Introdução ao Redu: a rede social educacional' }
        let(:youtube_url) { 'http://www.youtube.com/watch?v=jLMKkXTf92o' }
        let(:youtube_embed_url) { 'http://www.youtube.com/embed/jLMKkXTf92o' }

        before do
          fill_in 'URL', :with => youtube_url
        end

        it 'shows the preview and creates the lecture' do
          within '#new_lecture' do
            # Verifica se o preview do vídeo apareceu
            page.should have_css "#youtube_preview " \
              "iframe[src='#{youtube_embed_url}']"

            # Verifica se o nome do vídeo apareceu
            find('#lecture_name').value.should == youtube_name

            click_on 'Adicionar'
          end

          page.should have_no_css '#new_lecture'

          verify_item_created(Lecture.last, youtube_name)
          verify_page_show(Lecture.last, {
            :name => youtube_name,
            :player_css => "object[type='application/x-shockwave-flash']"
          })
        end
      end
    end
  end

  private
  # Visualiza a página e verifica se o conteúdo foi salvo
  def verify_page_show(lecture, attrs)
    visit space_subject_lecture_path(space, subj, lecture)
    page.should have_content attrs[:name]
    page.should have_css attrs[:player_css]
  end
end
