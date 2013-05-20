# -*- encoding : utf-8 -*-
Factory.define :higher_education do |h|
  h.kind "bachelorship"
  h.sequence(:institution) { |n| "Institution #{n}" }
  h.start_year Date.today - 1.year
  h.end_year Date.today + 3.year
  h.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam."
  h.course "Course"
end
