module Api
  module FolderAbility
    extend ActiveSupport::Concern

    def folder_abilities(user)
      @tutor_role ||= Role[:tutor]

      if user
        can(:read, Folder) { |f| can? :read, f.space }
        can(:manage, Folder) { |f| can? :manage, f.space }
        can :manage, Folder do |f|
          f.space.user_space_associations.exists?(:user_id => user,
                                                  :role => @tutor_role)
        end
      end
    end
  end
end
