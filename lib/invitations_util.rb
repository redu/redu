module InvitationsUtil
  #   Processa a requisição de convite de amizade (por email e
  # por id do usuário cadastrado no redu), seguindo as regras
  # de negócio relacionadas a criação de requisições de amizade.
  #
  # @params => parâmetros da requisição (:friend_id | :emails)
  # @user => remetente do convite
  def self.process_invites(params, user)
    friend = process_friendships(params['friend_id'].to_s, user) unless params['friend_id'].to_s.strip == ""
    process_invitations(params['emails'].to_s, user) unless params['emails'].to_s.strip == ""
    return friend
  end

  #   Destrói em batch as requisições de amizade selecionadas
  # pelo usuário.
  #
  # @params => parâmetros da requisição (:invitations | :friendship_requests)
  # @user => Usuário logado, que está gerenciando seus convites
  def self.destroy_invitations(params, user)
    invitations = params['invitations'] || ""
    invitations = invitations.collect{ |invitation_id| invitation_id.to_i }
    friendship_requests = params['friendship_requests'] || ""
    friendship_requests = friendship_requests.collect{ |friendship_id| friendship_id.to_i}

    invitations.each do |invitation_id|
      invitation = Invitation.find(invitation_id)
      invitation.destroy
    end

    friendship_requests.each do |friendship_id|
      friendship_request = Friendship.find(friendship_id)
      friend = User.find(friendship_request.friend_id)
      friendship_receive = friend.friendship_for(user)

      friendship_request.destroy
      friendship_receive.destroy
    end
  end

  # Private method
  def self.process_friendships(invited_friends, user)
    friends = invited_friends.to_s.gsub(',',' ').split
    if friends.size > 0
      friends.each do |friend_id|
        friend = User.find(friend_id)
        user.be_friends_with(friend)
        #Retona o 1 friend convidado (no caso de convite único)
      end
      User.find(friends.first)
    end
  end

  # Private method
  def self.process_invitations(invited_friends, user)
    emails =invited_friends.to_s.gsub(',',' ').split
    emails.each do |email|
      invitee = User.where(:email => email)
      if invitee.empty?
        Invitation.invite(:user => user,
                          :hostable => user,
                          :email => email) do |invitation|
          UserNotifier.friendship_invitation(invitation).deliver
        end
      else
        process_friendships(invitee.first.id, user)
      end
    end
  end
  private_class_method :process_friendships, :process_invitations
end
