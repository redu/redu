require 'spec_helper'

describe MyfileService do
  context "creating file" do
    let(:file) do
      File.open("#{Rails.root}/spec/fixtures/api/pdf_example.pdf")
    end
    let(:quota) { mock_model('Quota') }
    let(:ability) { mock('Ability') }
    let(:model_attrs) { { :attachment => file } }
    let(:params) do
      model_attrs.merge({ :quota => quota, :ability => ability })
    end
    subject do
      MyfileService.new(params)
    end
    before do
      ability.stub(:authorize!).and_return(true)
      quota.stub(:refresh!)
    end

    context "#create" do

      it "should create a Myfile" do
        expect {
          subject.create
        }.to change(Myfile, :count).by(1)
      end

      it "should accept a block" do
        myfile = subject.create do |myfile|
          myfile.user = Factory(:user)
        end

        myfile.user.should_not be_nil
      end

      it "should deletgate to Ability's authorize!" do
        subject.ability.should_receive(:authorize!).
          with(:upload_file, an_instance_of(Myfile))
        subject.create
      end

      it "should raise exception when there's no authorization" do
        ability.stub(:authorize!).
          and_raise(CanCan::AccessDenied.new("Not authorized!"))

        expect {
          subject.create
        }.to raise_error(CanCan::AccessDenied)
      end

      it "should #refresh! quota" do
        subject.quota.should_receive(:refresh!)
        subject.create
      end

      it "should not #refresh! if Myfile is not saved" do
        subject.stub(:build).and_return(Myfile.new)
        subject.create
        subject.quota.should_not_receive(:refresh!)
      end
    end


    context "#build" do
      it "should instanciate MyFile" do
        model = mock_model('Myfile')
        subject.stub(:model_class).and_return(model)

        model.should_receive(:new).with(model_attrs)

        subject.build
      end

      it "should yield to Myfile.new" do
        expect { |b| subject.build(&b) }.
          to yield_with_args(an_instance_of(Myfile))
      end
    end

    context "#quota" do
      context "when passed to .new" do
        it "should return the quota passed to .new" do
          subject.quota.should == quota
        end
      end

      context "when not passed to .new" do
        let(:options) { { :ability => ability }.merge(model_attrs) }

        it "should infer the quota when it's not passed to .new" do
          folder = mock_model("Folder")
          folder.stub_chain(:space, :course, :quota).and_return(quota)

          service = MyfileService.new(options)

          service.create do |s|
            s.folder = folder
          end

          service.quota.should == quota
        end

        it "should return nil if the wasn't  created" do
          service = MyfileService.new(options)
          service.quota.should be_nil
        end
      end
    end
  end

end
