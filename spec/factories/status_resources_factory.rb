FactoryGirl.define do
  factory :status_resource do
    provider "http://www.youtube.com/"
    thumb_url "http://www.youtube.com/watch?v=mUceNnaCfFo"
    title "Lost Planet 3 | Announcement Trailer"
    description "New Lost Planet 3 Trailer has been revealed from Capcom's Captivate 2012 Event. Release Date is 2013."
    link "http://www.youtube.com/watch?v=mUceNnaCfFo"
    sequence :status_id do |n|
      "#{n}"
    end
  end
end