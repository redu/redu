require 'spec_helper'

describe LectureableCanvasService do
  let(:client) { FactoryBot.create(:client_application) }
  let(:lecture) { FactoryBot.build_stubbed(:lecture) }
  let(:ability) { mock('Ability') }
  let(:access_token) do
    t = mock('AccessToken')
    t.stub(:user).and_return(lecture.owner)
    t.stub(:client_application_id).and_return(client.id)
    t
  end
  let(:canvas_attrs) { FactoryBot.attributes_for(:canvas) }

  subject do
    LectureableCanvasService.
      new(ability, canvas_attrs.merge(:access_token => access_token))
  end

  context "#create" do
    let(:canvas) { subject.create(lecture) }
    it "should return a saved Canvas" do
      canvas.should be_a Api::Canvas
      canvas.should be_persisted
    end

    it "should set the container to the lecture" do
      canvas.container.should == lecture
    end
  end
end
