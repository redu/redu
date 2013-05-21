# -*- encoding : utf-8 -*-
shared_examples_for "embeds user" do
  it "should have key user" do
    entity.should have_key('user')
  end

  it "should embed user" do
    entity['user']['id'].should == user.id
  end
end
