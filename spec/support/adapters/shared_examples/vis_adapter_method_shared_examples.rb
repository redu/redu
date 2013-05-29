# -*- encoding : utf-8 -*-
shared_examples_for "vis adapter method" do |method, message=nil|
  before(:all) do
    message ||= method.to_s.gsub("notify_", "")
  end

  let(:vis_adapter) { described_class.new }

  describe "##{method}" do
    context "with an array" do
      it "should invoke VisClient with correct arguments" do
        set_vis_client_expectation(message, items)
        vis_adapter.public_send(method, items)
      end
    end

    context "with an ActiveRecord::Relation" do
      it "should invoke VisClient with correct arguments" do
        set_vis_client_expectation(message, items)
        vis_adapter.public_send(method, items_arel)
      end
    end
  end

  def set_vis_client_expectation(message, items)
    VisClient.should_receive(:notify_delayed).
      with("/hierarchy_notifications.json", message, items)
  end
end

