module StatusesHelper
  def role_at(user, entity)
    association = user.get_association_with(entity)
    return "" if association.nil?

    Role[association.try(:role)]
  end
end
