class Activity < Status
  validates_presence_of :text
  validates_length_of :text, :maximum => 500
end
