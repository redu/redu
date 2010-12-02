class Asset < ActiveRecord::Base
  belongs_to :subject
  belongs_to :assetable, :polymorphic => true
  belongs_to :lazy_asset

  named_scope :lectures, :conditions => { :assetable_type => "Lecture" }
  named_scope :exams, :conditions => { :assetable_type => "Exam" }
end
