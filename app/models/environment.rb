class Environment < ActiveRecord::Base
  # Representa o ambiente onde o ensino a distância acontece. Pode ser visto
  # como um instituição o provedor de ensino dentro do sistema.

  has_many :courses, :dependent => :destroy
  has_many :user_environment_associations, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "owner"
  has_many :users, :through => :user_environment_associations
  has_attached_file :avatar, PAPERCLIP_STORAGE_OPTIONS.merge({
    :styles => { :thumb => "140x100>" }
  })
  has_many :invitations, :class_name => "EnvironmentInvitation",
    :dependent => :destroy
  has_many :bulletins, :as => :bulletinable, :dependent => :destroy

  acts_as_taggable

  validates_presence_of :name

  accepts_nested_attributes_for :courses, :invitations

  # Sobreescrevendo ActiveRecord.find para adicionar capacidade de buscar por path do Space
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_path(args)
    else
      super
    end
  end

  def to_param
    self.path
  end

  def permalink
    "#{AppConfig.community_url}/#{self.path}"
  end

  # Muda o papel do usuário levando em conta a hierarquia
  def change_role(user, role)
    membership = self.user_environment_associations.find(:first,
                    :conditions => {:user_id => user.id})
    membership.update_attributes({:role_id => role.id})

      user.user_course_associations.all(
        :conditions => {:course_id => self.courses}).each do |membership|
        membership.course.change_role(user, role)
      end
  end
end
