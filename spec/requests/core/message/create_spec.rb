require 'request_spec_helper'

describe "Messages" do
  let(:user) { Factory(:user, :first_name => "Darth",
                       :last_name => "Vader") }
  let(:friend) { Factory(:user, :first_name => "Luke",
                         :last_name => "Skywalker") }

  describe "Creation" do
    before do
      login_as(user)
      user.be_friends_with(friend)
      friend.be_friends_with(user)
    end

    it "send a message to another user", :js => true do
      click_on "Mensagens"
      click_on "Nova"
      fill_in_to "Luke Skywalker"
      select_from_helper_list(friend.display_name)
      click_out
      fill_in "Assunto:", :with => "Parternity"
      fill_in "Mensagem:", :with => "I'm your father!"
      click_button "Enviar"
      page.should have_content("Mensagem enviada!")
      page.should have_content("Parternity")
      current_path.should == index_sent_user_messages_path(user)
    end

    it "try to send a message to another user, raise all of validations" do
      click_on "Mensagens"
      click_on "Nova"
      click_button "Enviar"
      page.should have_content("Mensagem Por favor, digite uma mensagem.")
      page.should have_content("Assunto Por favor, digite um assunto.")
      page.should have_content("Para Destinatário inexistente, digite um válido.")
    end
  end

  private

  def fill_in_to(key)
    page.find('form#new_message ul li .maininput').set(key)
    sleep 2
  end

  def select_from_helper_list(key)
    within '#message_to_feed' do |teste|
      all('li').each do |li|
        li.click if li.text =~ /#{key}/
      end
    end
  end

  def click_out
    # Tive de fazer isso já que a mensagem impede o click no botão
    find('.panel').click
  end
end
