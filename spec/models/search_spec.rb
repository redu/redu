require 'spec_helper'

describe Search do
  let(:subject) { Search.new(User) }

  it { should respond_to(:klass) }
  it { should respond_to(:config) }
  it { should respond_to(:search) }

  describe :search do

    it 'should call Sunspot::search method for User' do
      search = Search.new(User)
      User.should_receive(:search).once

      search.search({ :query => 'Eita' })
    end

    it 'should call Sunspot::search method for Environment' do
      search = Search.new(Environment)
      Environment.should_receive(:search).once

      search.search({ :query => 'Eita' })
    end

    it 'should call Sunspot::search method for Course' do
      search = Search.new(Course)
      Course.should_receive(:search).once

      search.search({ :query => 'Eita' })
    end

    it 'should call Sunspot::search method for Space' do
      search = Search.new(Space)
      Space.should_receive(:search).once

      search.search({ :query => 'Eita' })
    end
  end
end
