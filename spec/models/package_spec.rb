require 'spec_helper'

describe Package do
  subject { FactoryGirl.create(Package) }
  context "#update_data_bag" do
    it "updates data bag using DataBagResource" do
      DataBagResource.should_receive(:create_or_updatei_item)
      subject.update_data_bag
    end

    it "sets data_bag_updated_at" do
      Timecop.freeze do
        DataBagResource.stub(:create_or_update_item).and_return(true)
        subject.data_bag_updated_at.should be_nil
        subject.update_data_bag
        subject.data_bag_updated_at.should == Time.now
      end
    end
  end
end
