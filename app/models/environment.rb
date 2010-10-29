class Environment < ActiveRecord::Base
  # Representa o ambiente onde o ensino a distância acontece. Pode ser visto
  # como um instituição o provedor de ensino dentro do sistema.

  has_many :courses, :dependent => :destroy
  has_attached_file :avatar, {
    :styles => { :medium => "200x200>", :thumb => "100x100>", :nano => "24x24>" },
    :path => "environments/:attachment/:id/:style/:basename.:extension",
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  accepts_nested_attributes_for :courses
  validates_presence_of :name
end
