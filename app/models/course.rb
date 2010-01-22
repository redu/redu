class Course < ActiveRecord::Base
 
  # PLUGINS
  acts_as_commentable
  acts_as_taggable
  ajaxful_rateable :stars => 5#, :dimensions => [:speed, :beauty, :price]
  
  # ASSOCIATIONS
  has_and_belongs_to_many :subjects
  
  has_many :acess_key
  has_and_belongs_to_many :resources
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  has_many :course_prices
  has_many :acquisitions
  belongs_to :main_resource, :class_name => "Resource"
  
  # Virtual attributes
  attr_writer :main_resource_id
  
  # Callbacks
  before_validation_on_update :assing_main_resource_id
  # VALIDATIONS
  accepts_nested_attributes_for :course_prices, :main_resource
  validates_presence_of :name
  validates_presence_of :description
  
  # Verify
  #validate :course_cannot_have_unpublished_resources, :if => "self.published == true"
  
  def main_resource_id
    self.main_resource.id
  end
  
  def assing_main_resource_id
    if @main_resource_id
      self.main_resource = Resource.find(@main_resource_id) if Resource.exists?(@main_resource_id)
    end 
  end
  
  # Hack in order to make nested validation_group work.
	def validation_group_enabled?
		false
	end 

  def course_cannot_have_unpublished_resources
    msg = "Você não pode adicionar materiais não públicados à uma aula pública"
    errors.add(:main_resource, msg) if self.main_resource.published == false
    
      self.resources.each do |r|
        errors.add(:resource_ids, r.title + ": " + msg) if r.published == false
      end    
  end
  
  
  
end
