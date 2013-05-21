# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Error do
  before do
    @err = Error.new("mensagem")
  end

  it { @err.should respond_to :error }

  it "initialize" do
    @err.error.should eq("mensagem")
  end
end
