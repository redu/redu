require 'spec_helper'

describe "/friendships/decline" do
  before(:each) do
    render 'friendships/decline'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/friendships/decline])
  end
end
