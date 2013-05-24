# -*- encoding : utf-8 -*-
module StatusesHelper
  def role_at(user, entity)
    association = user.get_association_with(entity)
    return "" if association.nil?

    Role[association.try(:role)]
  end

  def status_message(msg)
    # Processa aspas envolvendo links e quebras de linha
    raw auto_link(h(msg).gsub(/\n/, '</br>').gsub(/&quot\;/, '"'))
  end

  def can_render_status?(status)
    is_a_log = true if status.logeable_type

    status.statusable && (is_a_log ? status.logeable : true)
  end
end
