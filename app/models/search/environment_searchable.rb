# -*- encoding : utf-8 -*-
module EnvironmentSearchable
  extend ActiveSupport::Concern

  included do
    searchable do
      text :name, :boost => 6.0
      text :initials, :boost => 5.0

      text :administrators, :boost => 3.0 do
        administrators.map { |a| a.display_name + "  " }
      end
    end
  end
end
