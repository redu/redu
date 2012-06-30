require 'request_spec_helper'

describe "Messages" do
  let(:user) { Factory(:user, :first_name => "Darth",
                       :last_name => "Vader") }
  let(:friend) { Factory(:user, :first_name => "Luke",
                         :last_name => "Skywalker") }

  describe "Remove message" do
    before do
      login_as(user)
      user.be_friends_with(friend)
      friend.be_friends_with(user)
    end

    it "remove message from index box" do
      msg = Factory(:message, :sender => friend, :recipient => user,
                    :subject => "Paternity")
      click_on "Mensagens"
      check("delete_")
      click_on "Remover selecionados"
      page.should have_content("As mensagens foram deletadas.")
      page.should_not have_content("Paternity")
      current_path.should == user_messages_path(user)
    end

    it "remove message from index sent box" do
      msg = Factory(:message, :sender => user, :recipient => friend,
                    :subject => "Paternity")
      click_on "Mensagens"
      click_on "Enviadas"
      check("delete_")
      click_on "Remover selecionados"
      page.should have_content("As mensagens foram deletadas.")
      page.should_not have_content("Paternity")
      current_path.should == index_sent_user_messages_path(user)
    end
  end
end
