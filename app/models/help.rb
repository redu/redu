class Help < Status
  include ActsAsActivity
  validates :statusable_type, :inclusion => { :in => ['Lecture'] }
end
