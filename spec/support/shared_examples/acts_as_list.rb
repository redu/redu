shared_examples_for "acts as list" do
  let(:list_accessor) { described_class.to_s.downcase.pluralize }

  context ".create" do
    context "without position" do
      context "and the list is empty" do
        let(:item) do
          Factory(described_class.to_s.downcase.to_sym,
                  scope_class.to_s.downcase.to_sym => scope_instance,
                  :position => nil)
        end

        it "should set the position to 1" do
          item.reload
          item.position.should_not be_nil
          item.position.should == 1
        end
      end

      context "and the list is not empty" do
        let(:item) do
          Factory(described_class.to_s.downcase.to_sym,
                  scope_class.to_s.downcase.to_sym => scope_instance_with_3_items,
                  :position => nil)
        end

        it "should set the position to 4" do
          item.reload
          item.position.should_not be_nil
          item.position.should == 4
        end
      end
    end
  end

  context "responders" do
    [:position, :last_item?, :first_item?, :last_item, :first_item,
     :next_item, :previous_item].each do |method|
      it "should respond to #{method}"  do
        subject.should respond_to(method)
      end
     end
  end

  context "#last_item?" do
    let(:scope_instance) { scope_instance_with_3_items }

    it "should return true when the item is the last" do
      last = scope_instance.send(list_accessor).last
      last.should be_last_item
    end

    it "should return false when the item is not the last" do
      first = scope_instance.send(list_accessor).first
      first.should_not be_last_item

      middle = scope_instance.send(list_accessor)[1]
      middle.should_not be_last_item
    end
  end

  context "#first_item?" do
    let(:scope_instance) { scope_instance_with_3_items }

    it "should return true when the item is the first" do
      first = scope_instance.send(list_accessor).first
      first.should be_first_item
    end

    it "should return false when the item is not the first" do
      last = scope_instance.send(list_accessor).last
      last.should_not be_first_item

      middle = scope_instance.send(list_accessor)[1]
      middle.should_not be_first_item
    end
  end

  context "#last_item" do
    let(:scope_instance) { scope_instance_with_3_items }

    it "should return the last item of the list" do
      item = scope_instance.send(list_accessor).first
      item.last_item.should == scope_instance.send(list_accessor).last
    end
  end

  context "#first_item" do
    let(:scope_instance) { scope_instance_with_3_items }

    it "should return the first item of the list" do
      item = scope_instance.send(list_accessor).last
      item.first_item.should == scope_instance.send(list_accessor).first
    end
  end

  context "#next_item" do
    let(:scope_instance) { scope_instance_with_3_items }

    it "should return the next item of the list" do
      first = scope_instance.send(list_accessor).first
      first.next_item.should == scope_instance.send(list_accessor)[1]

      item = scope_instance.send(list_accessor)[1]
      item.next_item.should == scope_instance.send(list_accessor)[2]
    end

    it "should return nil if it is the last item of the list" do
      last = scope_instance.send(list_accessor).last
      last.next_item.should be_nil
    end
  end

  context "#previous_item" do
    let(:scope_instance) { scope_instance_with_3_items }

    it "should return the previous item of the list" do
      last = scope_instance.send(list_accessor).last
      length = scope_instance.send(list_accessor).length
      last.previous_item.should == scope_instance.send(list_accessor)[length - 2]

      item = scope_instance.send(list_accessor)[1]
      item.previous_item.should == scope_instance.send(list_accessor)[0]
    end

    it "should return nil if it is the first item of the list" do
      first = scope_instance.send(list_accessor).first
      first.previous_item.should be_nil
    end
  end

  context "#item_at_offset" do
    let(:scope_instance) { scope_instance_with_3_items }

    it "should return the item with specified negative offset" do
      item = scope_instance.send(list_accessor).last
      length = scope_instance.send(list_accessor).length
      item.item_at_offset(-2).should ==
        scope_instance.send(list_accessor)[length - 3]
    end

    it "should return the item with specified positive offset" do
      item = scope_instance.send(list_accessor).first
      length = scope_instance.send(list_accessor).length
      item.item_at_offset(2).should ==
        scope_instance.send(list_accessor)[2]
    end

    it "should return nil if can't find the item with neg specified offset" do
      item = scope_instance.send(list_accessor).first
      item.item_at_offset(-1).should be_nil
    end

    it "should return nil if can't find the item with pos specified offset" do
      item = scope_instance.send(list_accessor).last
      item.item_at_offset(2).should be_nil
    end
  end
end
