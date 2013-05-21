# -*- encoding : utf-8 -*-
class Alternative < ActiveRecord::Base
  belongs_to :question
  has_many :choices, :dependent => :destroy

  validates_presence_of :text
end
