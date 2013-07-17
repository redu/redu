# -*- encoding : utf-8 -*-
class Page < ActiveRecord::Base
  has_one :lecture, :as => :lectureable
  validates_presence_of :body
end
