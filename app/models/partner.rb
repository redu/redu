class Partner < ActiveRecord::Base
  has_many :partner_environment_associations
  has_many :environments, :through => :partner_environment_associations
  has_many :users, :through => :partner_user_associations
  has_many :partner_user_associations

  validates_presence_of :name

  def add_collaborator(user)
    self.users << user
    self.environments.all(:include => :courses).each do |e|
      UserEnvironmentAssociation.create(:environment => e,
                                        :user => user,
                                        :role => Role[:environment_admin])

      e.courses.each do |c|
        c.create_hierarchy_associations(user, Role[:environment_admin])
        ass = UserCourseAssociation.create(:user => user,
                                     :course => c,
                                     :role => Role[:environment_admin])
        ass.approve!
      end
    end
  end
end
