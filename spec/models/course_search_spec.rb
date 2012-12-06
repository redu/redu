require 'spec_helper'

describe CourseSearch do

  it_behaves_like "a Sunspot::Search performer", Course
end
