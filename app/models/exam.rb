class Exam < ActiveRecord::Base
  
  has_many :question_exam_association
  has_many :questions, :through => :question_exam_association, :include => :alternatives
  #, :counter_cache => true
  
  belongs_to :author , :class_name => "User" , :foreign_key => "author_id"
  #, :counter_cache => true
  # :counter_cache => true para ter uma coluna que conta o numero
  
  validates_presence_of :name
=begin  
  def current_question
    @current_question
  end
=end
  
=begin
  acts_as_state_machine :initial => :q0
  
  state :q10, :after => :current_question
  
  def init
    
     #aasm_initial_state 'q0'
    self.state :q11, :after => :current_question
     
    for k in 0..self.questions.length do
      #question = self.questions[k]
      state 'q' + k.to_s
    end
    
    
    event :next do
      for k in 0..(self.questions.length-1)
      transitions :to => 'q'+(k+1).to_s, :from => 'q'+k.to_s
      end
    end
    
  end
  
  def current_question
    @current_question ||= find_question(self.current_state)
  end
=end  
  
end
