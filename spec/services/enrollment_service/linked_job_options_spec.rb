# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  module Jobs
    describe LinkedJobOptions do
      let!(:social_networks) do
        FactoryBot.create_list(:social_network, 2, user: nil)
      end

      subject { LinkedJobOptions.new }

      context "#set" do
        it "should keep the ids when an ActiveRecord::Relation" do
          subject.set(:social_network, SocialNetwork.limit(2))
          subject.ids(:social_network).should =~ social_networks.map(&:id)
        end

        it "should keep the ids when passing a collection" do
          subject.set(:social_network, SocialNetwork.all.to_a)
          subject.ids(:social_network).should =~ social_networks.map(&:id)
        end

        it "should remain nil when setting a nil options" do
          subject.set(:social_network, nil)
          subject.ids(:social_network).should be_nil
        end
      end

      context "#ids" do
        it "should return the ids" do
          subject.set(:social_network, social_networks)
          subject.ids(:social_network).should =~ social_networks.map(&:id)
        end
      end

      context "#arel_of" do
        it "should return an ActiveRecord::Relation" do
          subject.set(:social_network, social_networks)
          subject.arel_of(:social_network).should be_a ActiveRecord::Relation
        end

        it "should return the correct values" do
          subject.set(:social_network, social_networks)
          subject.arel_of(:social_network).should =~ social_networks
        end
      end
    end
  end
end
