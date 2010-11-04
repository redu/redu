class Environment < ActiveRecord::Base
  # Representa o ambiente onde o ensino a distância acontece. Pode ser visto
  # como um instituição o provedor de ensino dentro do sistema.

  has_many :courses, :dependent => :destroy
  has_many :user_environment_association, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "owner"
  has_many :users, :through => :user_environment_association
  has_attached_file :avatar, PAPERCLIP_STORAGE_OPTIONS.merge({
    :styles => { :thumb => "140x100>" }
  })
  has_many :invitations, :class_name => "EnvironmentInvitation",
    :dependent => :destroy

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

end
