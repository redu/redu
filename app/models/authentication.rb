class Authentication < ActiveRecord::Base
  belongs_to :user
  validates :uid, :provider, :presence => true
  validates_uniqueness_of :uid, :scope => :provider

  # Lida com tokens de convite recebendo como parâmetro o estado retornado do
  # serviço de autenticação e o usuário que recebeu o convite
  def self.handle_invitation_token(state, user)
    state = parse(state)
    if state
      # Convite para curso
      if state.has_key?("invitation_token") &&
        invite = UserCourseInvitation.find_by_token(state["invitation_token"])

        invite.user = user
        invite.accept!
        # Solicitação de amizade
      elsif state.has_key?("friendship_invitation_token") &&
        invite = Invitation.find_by_token(state["friendship_invitation_token"])

        invite.accept!(user)
      end
    end
  end

  private

  # Transforma uma string em JSON ou retorna nil caso o parseamento seja impossível
  def self.parse(string)
    begin
      JSON.parse(string)
    rescue JSON::ParserError
      nil
    end
  end
end
