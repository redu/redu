module StatusesHelper
  def role_at(user, entity)
    association = user.get_association_with(entity)
    return "" if association.nil?

    Role[association.try(:role)]
  end

  def status_message(msg)
    # Processa quebras de linha
    status = msg.gsub(/\n/, '</br>')

    # Processa aspas envolvendo links
    status = h(status).gsub(/&quot;/, '"')

    raw auto_link(status)
  end
end
