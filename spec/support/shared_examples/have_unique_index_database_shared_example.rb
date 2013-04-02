shared_examples_for 'have unique index database' do
  context "when application uniqueness validation fail" do
    it "should prevent duplicate insertion on db (raise RecordNotUnique)" do
      expect {
        duplicate = subject.class.new(subject.attributes)
        duplicate.save(:validate => false)
      }.should raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
