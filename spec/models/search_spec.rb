# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Search do
  let(:subject) { Search.new(User) }

  it { should respond_to(:klass) }
  it { should respond_to(:search) }

  describe "#search" do
    it 'should call Sunspot::search method for Class' do
      search = Search.new(User)
      User.should_receive(:search).once

      search.search({ :query => 'Eita' })
    end
  end
end
