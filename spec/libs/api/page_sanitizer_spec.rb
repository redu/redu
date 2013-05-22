# -*- encoding : utf-8 -*-
require "spec_helper"

module Api
  describe PageSanitizer do
    subject { PageSanitizer.new }

    it "should convert HTML entities to UTF-8 chars" do
      PageSanitizer.new("<p>&ouml;<p>").sanitize.should == "ö"
    end

    it "should strip links" do
      PageSanitizer.new("<a href='http://google.com'>Há</a>").sanitize.
        should == "Há"
    end
  end
end
