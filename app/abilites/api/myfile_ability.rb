module Api
  module MyfileAbility
    extend ActiveSupport::Concern

    def myfile_abilities(user)
      if user
        can(:read, Myfile) { |f| can? :read, f.folder }
        can(:manage, Myfile) { |f| can? :manage, f.folder }
      end
    end
  end
end
