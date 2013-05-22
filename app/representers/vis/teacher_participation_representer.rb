# -*- encoding : utf-8 -*-
module Api
  module TeacherParticipationRepresenter
    include Roar::Representer::JSON

    property :lectures_created
    property :posts
    property :answers
    property :days

  end
end
