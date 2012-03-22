module HelpRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include ActivityRepresenter
  
end
