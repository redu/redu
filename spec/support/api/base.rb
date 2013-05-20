# -*- encoding : utf-8 -*-
module Api
  module Helpers
    def parse(json)
      ActiveSupport::JSON.decode(json)
    end

    def href_to(rel, representation)
      link = representation.fetch('links', []).
        detect { |link| link['rel'] == rel }

      link ? link['href'] : ''
    end
  end
end

