# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe StatusDependenciesEntityService do
    subject { StatusDependenciesEntityService.new(statuses: statuses) }
    let(:statuses) { FactoryBot.build_stubbed_list(:activity, 2) }

    describe "#destroy" do
      it 'should invoke self#destroy_dependency with Answer' do
        subject.should_receive(:destroy_dependency).with(Answer)
        subject.should_receive(:destroy_dependency).at_least(1)
        subject.destroy
      end

      it 'should invoke self#destroy_dependency with StatusUserAssociation' do
        subject.should_receive(:destroy_dependency).with(StatusUserAssociation)
        subject.should_receive(:destroy_dependency).at_least(1)
        subject.destroy
      end

      it 'should invoke self#destroy_dependency with StatusResource' do
        subject.should_receive(:destroy_dependency).with(StatusResource)
        subject.should_receive(:destroy_dependency).at_least(1)
        subject.destroy
      end
    end

    describe "#destroy_dependency" do
      shared_examples_for "#destroy_dependency" do
        it "should destroy statuses" do
          expect {
            subject.send(:destroy_dependency, klass)
          }.to change(klass, :count).
            by(-items.length)
        end
      end

      describe "#destroy_dependency(Answer)" do
        let(:items) do
          statuses.map do |status|
            FactoryBot.create_list(:answer, 2, in_response_to: status)
          end.flatten
        end
        let(:klass) { Answer }

        include_examples "#destroy_dependency"
      end

      describe "#destroy_dependency(StatusUserAssociation)" do
        let(:items) do
          statuses.map do |status|
            FactoryBot.create_list(:status_user_association, 2, status: status)
          end.flatten
        end
        let(:klass) { StatusUserAssociation }

        include_examples "#destroy_dependency"
      end

      describe "#destroy_dependency(StatusResource)" do
        let(:items) do
          statuses.map do |status|
            FactoryBot.create_list(:status_resource, 2, status: status)
          end.flatten
        end
        let(:klass) { StatusResource }

        include_examples "#destroy_dependency"
      end
    end
  end
end
