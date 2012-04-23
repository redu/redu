require 'action_view'

module PageRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include ActionView::Helpers::SanitizeHelper

  property :body
end
