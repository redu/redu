require 'spec_helper'

describe UserSetting do
  subject { Factory(:user_setting) }

  describe 'keep explored tour parts' do
    context 'when keeping' do
      it 'keeps explored tour parts' do
        subject.visit!("/ensine")
        subject.visit!("/cursos")
        subject.explored.should include("/ensine")
        subject.explored.should include("/cursos")
      end

      it 'does not include repeated tour parts' do
        subject.visit!("/ensine")
        subject.visit!("/ensine")
        subject.explored.should have(1).item
      end

      it 'keeps explored tour parts with ids instead of urls' do
        subject.visit!("#learn-environments")
        subject.explored.should include("#learn-environments")
      end

      it 'commits the new tour part to the database' do
        subject.visit!("/ensine")
        subject.reload

        subject.explored.should_not be_nil
        subject.explored.should include("/ensine")
      end
    end

    context 'when verifying' do
      it 'responds with true to visited urls' do
        subject.visit!("/ensine")
        subject.visited?("/ensine").should be_true
      end

      it 'responds with true to visited ids' do
        subject.visit!("#learn-environments")
        subject.visited?("#learn-environments").should be_true
      end

      it 'responds with false to not visited urls' do
        subject.visited?("/cursos").should be_false
      end

      it 'responds with false to not visited ids' do
        subject.visited?("#what-to-do").should be_false
      end
    end
  end
end
