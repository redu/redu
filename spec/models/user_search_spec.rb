require 'spec_helper'

describe UserSearch do

  it_behaves_like "a Sunspot::Search performer", User
end
