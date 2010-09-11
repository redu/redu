#!/usr/bin/ruby
require "rubygems"
require "icalendar"
require "tzinfo"
require "icalendar/tzinfo"
include Icalendar


# Now, you can make timezones like this
tz = TZInfo::Timezone.get("America/Chicago")

cal = Calendar.new

cal.add(tz.ical_timezone(DateTime.now))

e = cal.event do
    dtstart       DateTime.new(2008, 12, 29, 8, 0, 0)
    dtend         DateTime.new(2008, 12, 29, 11, 0, 0)
    summary     "Meeting with the man."
    description "Have a long lunch meeting and decide nothing..."
    klass       "PRIVATE"
  end

#e.dtstart.ical_params = {"TZID" => "America/Chicago"}
#e.dtend.ical_params = {"TZID" => "America/Chicago"}

puts cal.to_ical

