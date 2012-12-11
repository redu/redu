shared_examples_for "a Sunspot::Search performer" do

  it { should be_a_kind_of(Search) }
  it { should respond_to(:perform) }
  its(:klass) { should eq(subject) }

  describe :perform do
    let(:performer) { subject.class.new }
    let(:query) { 'Query' }
    let(:page) { 1 }

    it "should call Search::search method" do
      performer.should_receive(:search).once

      performer.perform(query, page)
    end
  end
end
