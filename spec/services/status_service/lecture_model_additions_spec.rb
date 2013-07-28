# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe Lecture do
    it "should include BaseModelAdditions" do
      described_class.should include(BaseModelAdditions)
    end

    it "should include StatusableAdditions::ModelAdditions" do
      described_class.should include(StatusableAdditions::ModelAdditions)
    end
  end
end
