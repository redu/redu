# -*- encoding : utf-8 -*-
require 'spec_helper'

describe VisAdapter do
  describe ".initialize" do
    context "without arguments" do
      let(:vis_adapter) { described_class.new }

      it "should set vis_client" do
        vis_adapter.vis_client.should == VisClient
      end

      it "should set url" do
        vis_adapter.url.should == "/hierarchy_notifications.json"
      end
    end

    context "with vis_client and url arguments" do
      let(:vis_adapter) do
        described_class.new(vis_client: Enrollment, url: "/new_url.json")
      end

      it "should set vis_client" do
        vis_adapter.vis_client.should == Enrollment
      end

      it "should set url" do
        vis_adapter.url.should == "/new_url.json"
      end
    end
  end
end
