# -*- encoding : utf-8 -*-
module Vis
  module TeacherParticipationRepresenter
    include Roar::Representer::JSON

    property :lectures_created
    property :posts
    property :answers
    property :days

  end
end
