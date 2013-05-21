# -*- encoding : utf-8 -*-
module Vis
  module StatusVisRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :user_id
    property :lecture_id
    property :subject_id
    property :space_id
    property :course_id
    property :status_id
    property :statusable_id
    property :statusable_type
    property :in_response_to_id
    property :in_response_to_type
    property :created_at
    property :updated_at

    def status_id
      self.id
    end

  end
end
