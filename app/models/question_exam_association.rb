class QuestionExamAssociation < ActiveRecord::Base

  belongs_to :question, :dependent => :destroy
  belongs_to :exam, :dependent => :destroy

  acts_as_list :scope => :exam

end
