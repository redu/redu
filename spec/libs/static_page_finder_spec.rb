require 'spec_helper'

describe StaticPageFinder do
  context "#template" do
    it "should default to pages/:layout/:page_id" do
      StaticPageFinder.new(:page_id => "authoring").template.should == \
        "pages/basic/authoring"
    end

    it "should fallback to pages/:page_id when there is no view with page_id" do
      StaticPageFinder.new(:page_id => "foo_bar").template.should ==\
        "pages/foo_bar"
    end
  end

  context "#layout" do
    it "should return nil when there is no view with page_id" do
      StaticPageFinder.new(:page_id => "foo_bar").layout.should be_nil
    end

    it "should return page_id dir name" do
      StaticPageFinder.new(:page_id => "authoring").layout.should == "basic"
    end
  end
end
