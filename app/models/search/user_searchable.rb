module UserSearchable
  extend ActiveSupport::Concern

  included do
    searchable do
      text :name, :boost => 6.0 do
        display_name
      end

      text :job, :boost => 4.0, :stored => true do
        experiences.actual_jobs.map{ |exp| exp.title + "  " }
      end

      # Places tem o mesmo boost
      text :birth_localization, :boost => 2.0
      text :localization, :boost => 2.0

      text :education_place, :boost => 2.0, :stored => true do
        education = most_important_education.first
        unless education.nil?
          education.educationable.institution + "  "
        end
      end

      text :workplace, :boost => 2.0, :stored => true do
        experiences.actual_jobs.map{ |exp| exp.company + "  " }
      end
    end
  end
end
