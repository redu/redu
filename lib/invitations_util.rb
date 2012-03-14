class InvitationsUtil
  #TODO: deve incluir o módulo invitation (quando for gem)
  FRIENDSHIP = 0
  FRIENDSHIP_STATUS = 1

  def self.process_invites(params, user)
    friend = InvitationsUtil.process_friendship(params['friend_id'], user) if params['friend_id']
    InvitationsUtil.process_invitation(params['emails'], user) if params['emails']
    return friend
  end

  private
  def self.process_friendship(invited_friends, user)
    friends = invited_friends.split(',')
    if friends.size > 0
      friends.each do |friend_id|
        friend = User.find(friend_id)
        friendship = user.be_friends_with(friend)[InvitationsUtil::FRIENDSHIP]
      end
      #Retona o 1 friend invitado (no caso de convite unico)
      User.find(friends.first)
    end
  end

  def self.process_invitation(invited_friends, user)
    emails = invited_friends.gsub(',', ' ').split
    if emails.size > 0
      emails.each do |email|
        Invitation.invite(:user => user, :hostable => user, :email => email) do |invitation|
          UserNotifier.friendship_invitation(invitation).deliver
        end
      end
    end
  end
end
