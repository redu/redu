require 'spec_helper'

describe StaticPageFinder do
  let(:options) do
    { :content_path => Rails.root.join("spec/support/static_page_finder_views/pages") }
  end

  context "#template" do
    it "should default to pages/:layout/:page_id" do
      finder("authoring").template.should == "pages/basic/authoring"
    end

    it "should fallback to pages/:page_id when there is no view with page_id" do
      finder("foo_bar").template.should == "pages/foo_bar"
    end
  end

  context "#layout" do
    it "should return nil when there is no view with page_id" do
      finder("foo_bar").layout.should be_nil
    end

    it "should return page_id dir name" do
      finder("authoring").layout.should == "basic"
    end
  end

  def finder(page_id)
    StaticPageFinder.new(options.merge(:page_id => page_id))
  end
end
