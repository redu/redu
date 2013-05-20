# -*- encoding : utf-8 -*-
Factory.define :status_resource do |s|
  s.provider "http://www.youtube.com/"
  s.thumb_url "http://www.youtube.com/watch?v=mUceNnaCfFo"
  s.title "Lost Planet 3 | Announcement Trailer"
  s.description "New Lost Planet 3 Trailer has been revealed from Capcom's Captivate 2012 Event. Release Date is 2013."
  s.link "http://www.youtube.com/watch?v=mUceNnaCfFo"
  s.association :status, :factory => :activity
end
