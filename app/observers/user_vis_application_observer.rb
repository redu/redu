class UserVisApplicationObserver < ActiveRecord::Observer
  # Observer responsável pela criação token para a aplicação ReduViz, utilizada
  # nas visualizações do Redu.

  observe User
  include VisApplicationAdditions::Utils

  def after_create(user)
    create_token_for(user)
  end
end
