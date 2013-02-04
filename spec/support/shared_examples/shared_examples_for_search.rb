shared_examples_for "a Sunspot::Search performer" do

  it { should be_a_kind_of(Search) }
  it { subject.class.should respond_to(:perform) }
  its(:klass) { should eq(subject) }

  describe :perform do
    let(:performer) { subject.class } # não é uma instância, mas sim a classe!
    let(:query) { 'Query' }
    let(:page) { 1 }
    let(:per_page) { 4 }

    it "should instantiate the search performer" do
      instantiation_method = performer.method(:new)
      performer.should_receive(:new).once do
        instantiation_method.call
      end

      performer.perform(query, per_page)
    end

    it "should perform search and return a Sunspot::Rails::StubSessionProxy::Search" do
      ret = performer.perform(query, per_page)
      ret.should be_instance_of(Sunspot::Rails::StubSessionProxy::Search)
    end
  end
end
