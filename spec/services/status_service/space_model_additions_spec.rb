# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe Space do
    it "should include BaseModelAdditions" do
      expect(described_class).to include(BaseModelAdditions)
    end

    it "should include StatusableAdditions::ModelAdditions" do
      expect(described_class).to include(StatusableAdditions::ModelAdditions)
    end
  end
end
