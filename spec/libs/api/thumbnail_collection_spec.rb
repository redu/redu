# -*- encoding : utf-8 -*-
require 'api_spec_helper'

describe "ThumbnailCollection" do
  let(:representer) { Api::UserRepresenter }
  let(:model) { FactoryBot.build(:user) }
  let(:representation) do
    model.extend(representer)
    model.to_hash
  end
  let(:thumbnails)  do
    model.avatar.styles.keys.collect do |thumb_size|
      height = width = thumb_size.to_s.gsub('thumb_', '')
      { :size => "#{width}x#{height}",
        :href => model.avatar.url(thumb_size) }
    end
  end

  it "representation should have thumbnails key" do
    representation.should have_key("thumbnails")
  end

  it "representation should have a list" do
    representation["thumbnails"].should be_a Array
  end

  it "representation should have the correct thumbnail's list" do
    representation["thumbnails"].to_set.should == thumbnails.to_set
  end
end
