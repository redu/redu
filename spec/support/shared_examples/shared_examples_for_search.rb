shared_examples_for "a Sunspot::Search performer" do |klass|

  it { should be_a_kind_of(Search) }
  it { should respond_to(:perform).with(2).arguments }
  its(:klass) { should eq(klass) }

  describe :perform do
    let(:performer) { "#{klass}Search".constantize.new }
    let(:query) { 'Query' }
    let(:page) { 1 }

    it "should call Search::search method" do
      performer.should_receive(:search).once

      performer.perform(query, page)
    end
  end
end
