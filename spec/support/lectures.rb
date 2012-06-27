module RequestsHelper
  # Confere o item da aula recém-criado
  def verify_item_created(lecture, name)
    within '#resources_list' do
      page.should have_content name
      page.should have_css "##{lecture.id}-item"
    end
  end
end
