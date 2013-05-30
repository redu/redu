# -*- enconding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  describe BaseModelAdditions do
    it_should_behave_like "BaseModelAdditions", EnrollmentService
  end
end
