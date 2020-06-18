# -*- encoding : utf-8 -*-
require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the QuestionsHelper. For example:
#
# describe QuestionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe QuestionsHelper do
  context "navigation" do
    let(:exercise) { FactoryBot.create(:exercise) }
    let(:questions) { 10.times.collect { FactoryBot.create(:question, :exercise => exercise )} }

    context "when first question" do
      it "should have a limit of 4" do
        limit, offset = helper.pagination(questions.first)
        limit.should == 4
      end

      it "should have a offset of 0" do
        limit, offset = helper.pagination(questions.first)
        offset.should == 0
      end
    end

    context "when second question" do
      it "should have a limit of 5" do
        limit, offset = helper.pagination(questions[1])
        limit.should == 5
      end

      it "should gave a offset of 0" do
        limit, offset = helper.pagination(questions[1])
        offset.should == 0
      end
    end

    context "when fifth question" do
      it "should have a limit of 7" do
        limit, offset = helper.pagination(questions[4])
        limit.should == 7
      end

      it "should gave a offset of 1" do
        limit, offset = helper.pagination(questions[4])
        offset.should == 1
      end
    end

    context "when seventh question" do
      it "should have a limit of 7" do
        limit, offset = helper.pagination(questions[6])
        limit.should == 7
      end

      it "should gave a offset of 3" do
        limit, offset = helper.pagination(questions[6])
        offset.should == 3
      end
    end

    context "when there are only one question" do
      let(:exercise) { FactoryBot.create(:exercise) }
      let(:question) { FactoryBot.create(:question, :exercise => exercise) }

      it "should have limit of 7" do
        limit, offset = helper.pagination(question)
        limit.should == 4
      end

      it "should have offset of 0" do
        limit, offset = helper.pagination(question)
        offset.should == 0
      end



    end
  end
end
