class InvitationsUtil
  #TODO: deve incluir o módulo invitation (quando for gem)
  FRIENDSHIP = 0
  FRIENDSHIP_STATUS = 1

  # params => parâmetros da requisição (:friend_id // :emails)
  # user => remetente do convite
  def self.process_invites(params, user)
    friend = process_friendships(params['friend_id'].to_s, user) unless params['friend_id'].to_s.strip == ""
    process_invitations(params['emails'].to_s, user) unless params['emails'].to_s.strip == ""
    return friend
  end

  private
  def self.process_friendships(invited_friends, user)
    friends = process_params(invited_friends)
    if friends.size > 0
      friends.each do |friend_id|
        friend = User.find(friend_id)
        user.be_friends_with(friend)
        #Retona o 1 friend invitado (no caso de convite unico)
      end
      User.find(friends.first)
    end
  end

  def self.process_invitations(invited_friends, user)
    emails = process_params(invited_friends)
    emails.each do |email|
      invitee = User.where(:email => email)
      if invitee.empty?
        Invitation.invite(:user => user, :hostable => user, :email => email) do |invitation|
          UserNotifier.friendship_invitation(invitation).deliver
        end
      else
        process_friendships(invitee.first.id, user)
      end
    end
  end

  def self.process_params(params)
    params.to_s.gsub(',',' ').split
  end
end
