require 'request_spec_helper'

describe "Invitations Management" do
  let(:usuario1) { Factory(:user) }
  let(:usuario2) { Factory(:user) }
  let(:usuario3) { Factory(:user) }

  describe "Manage friendship requests" do
    before do
      usuario2.be_friends_with(usuario1)
      login_as(usuario1)
    end

    context "when receive friendship requests" do
      context "when accept request" do
        it "should process request via ajax", :js => true do
          page.should have_content 'Você tem uma nova requisição de contato:'
          page.should have_link usuario2.display_name
          within '.friends-requisitions' do
            click_on 'Aceitar'
          end
          sleep 2
          current_path.should == home_user_path(usuario1)
          find('.friends-requisitions li').visible?.should be_false
        end
      end

      context "when reject request" do
        it "should process request via ajax", :js => true do
          page.should have_content 'Você tem uma nova requisição de contato:'
          page.should have_link usuario2.display_name

          within '.friends-requisitions' do
            click_on 'Recusar'
          end
          sleep 1
          current_path.should == home_user_path(usuario1)
          find('.friends-requisitions li').visible?.should be_false
        end
      end
    end

  end


  describe "Resend or Remove Invitations" do
    before do
      usuario1.be_friends_with(usuario2)
      usuario1.be_friends_with(usuario3)

      2.times do |n|
        Factory(:invitation,
                :user => usuario1,
                :hostable => usuario1,
                :email => "usuario#{n}@redu.com.br")
      end

      @invitations = Invitation.where(:user_id => usuario1.id)
      @friendship_requests = usuario1.friendships.requested

      login_as(usuario1)
      visit new_user_friendship_path(usuario1)
    end

    it "should display all invitations" do
      invitations = find('.invitation-list').all('.invite')
      invitations.should_not be_empty
      page.should have_content "Aguardando a resposta de #{invitations.count} membro(s)"
    end

    context "when remove sended friendship invitations", :js => true do
      it "should can destroy unique invitation" do
        within "#invitation-#{@invitations.first.to_param}" do
          check('invitations_ids[]')
        end

        count = find('.invitation-list').all('.invite').count
        click_on "Remover selecionados"
        sleep 2
        page.should have_content "Aguardando a resposta de #{count - 1} membro(s)"
      end

      it "should can destroy unique friendship request" do
        within "#request-#{@friendship_requests.first.to_param}" do
          check('friendship_requests[]')
        end
        count = find('.invitation-list').all('.invite').count
        click_on "Remover selecionados"
        sleep 3
        page.should have_content "Aguardando a resposta de #{count - 1} membro(s)"
      end

      it "should can destroy all items" do
        @invitations.each do |i|
          within "#invitation-#{i.to_param}" do
            check('invitations_ids[]')
          end
        end

        @friendship_requests.each do |r|
          within "#request-#{r.to_param}" do
            check('friendship_requests[]')
          end
        end

        click_on "Remover selecionados"
        sleep 5
        page.should have_content "Não há convites pendentes no momento"
      end
    end

    context "when resend invitations" do
      context "and those invitations are email invitations" do
        before do
          @invitation = @invitations.first
        end

        it "should change link name to 'Convite reenviado'", :js => true do
          within "#invitation-#{@invitation.to_param}" do
            click_on 'Reenviar convite'
          end
          find("#invitation-#{@invitation.to_param}").should have_content 'Convite reenviado'
        end
      end

      context "and those invitations are friendship requests"do
        before do
          @friendship_request = @friendship_requests.first
        end

        it "should change link name to 'Convite reenviado'", :js => true do
          within "#request-#{@friendship_request.to_param}" do
            click_on 'Reenviar convite'
          end
          find("#request-#{@friendship_request.to_param}").should have_content 'Convite reenviado'
        end
      end
    end
  end
end
