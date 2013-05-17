module Api
  module ExerciseRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia
    include LectureRepresenter
  end
end
