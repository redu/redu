# -*- encoding : utf-8 -*-
module CourseSearchable
  extend ActiveSupport::Concern

  included do
    searchable do
      text :name, :boost => 6.0

      text :owner, :boost => 3.0 do
        owner.display_name if owner
      end

      text :teachers, :boost => 3.0 do
        teachers.map { |t| t.display_name + "  " }
      end
    end
  end
end
