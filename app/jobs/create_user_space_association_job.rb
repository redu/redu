class CreateUserSpaceAssociationJob
  # Cria UserSpaceAssociation para todos os usuários que pertencem
  # ao curso (foram previamente aprovados)
  attr_accessor :space_id

  def initialize(opts)
    @space_id = opts[:space_id]
  end

  def perform
    if space = Space.find_by_id(@space_id)
      space.create_space_association_for_users_course
      space.create_policy_for_usa
    end
  end
end
