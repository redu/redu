# -*- encoding : utf-8 -*-
class Help < Status
  include StatusService::ActivityAdditions::ActsAsActivity
  validates :statusable_type, :inclusion => { :in => ['Lecture'] }
end
