require 'spec_helper'

describe Seminar do
  subject { Factory(:seminar) }

  it "should have one lecture" do
    pending "Need seminar factory" do
      should have_one :lecture
    end
  end

  it "validates youtube URL"
  it "truncates youtube URL"

end
