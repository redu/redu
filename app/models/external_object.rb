class ExternalObject < ActiveRecord::Base
  has_one :lesson, :as => :lesson
end
