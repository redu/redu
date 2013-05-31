# -*- encoding : utf-8 -*-
class Activity < Status
  include StatusService::ActivityAdditions::ActsAsActivity
end
