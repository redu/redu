require 'spec_helper'

describe Space do
  before do

  end

  context "associations" do

    it "belongs to a course"
    it "belongs to an owner"
    it "has many user space associations"
    it "has many users"
    it "has many teachers"
    it "has many students"
    it "has many logs"
    it "has many folders"
    it "has many bulletins"
    it "has many events"
    it "has many statuses"
    it "has many subjects"
    it "has many topics"
    it "has many sb_posts"
    it "has one forum"
    it "has one root folder"

  end

  context "validations" do

    [:name, :description, :submission_type].each do |attr|
      it "must have a #{attr}"
    end

  end

  context "finders" do

    it "retrieves published spaces"
    it "retrieves all spaces that belongs to a course"

  end

  context "callbacks" do
    it "creates a root folder"
  end

  it "generates a permalink"
  it "changes a user role"

end
