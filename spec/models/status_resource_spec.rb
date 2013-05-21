# -*- encoding : utf-8 -*-
require 'spec_helper'

describe StatusResource do

  it { should belong_to :status }
  it { should validate_presence_of :link }

end
