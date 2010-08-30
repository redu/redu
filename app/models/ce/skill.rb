class Skill < ActiveRecord::Base
  has_many :offerings
  has_many :users, :through => :offerings
  validates_uniqueness_of :name
  
  
  has_many :user_competences, :dependent => :destroy
  has_many :users, :through => :user_competences
  
  
  # categories
  belongs_to :parent, :class_name => "Skill", :foreign_key => "parent_id"
  has_many :sub_skills, :class_name => "Skill", :foreign_key => "parent_id"
  
  has_many :questions, :foreign_key => "skill_id"
  

  def to_param
    id.to_s << "-" << (name ? name.parameterize : '' )
  end
  
end
