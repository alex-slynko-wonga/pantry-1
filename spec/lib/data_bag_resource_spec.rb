require 'spec_helper'

describe DataBagResource do
  let(:data_bag_title) { 'DataBag' }
  let(:data_bag) { {'DataBagItem' => 'path' } }
  let(:item_title) { 'DataBagItem' }
  let(:value) { { version: 'test', name: 'test' } }
  let(:item) { {id: 'DataBagItem' } }

  describe "#create_or_update_item" do
    context "if data bag exist" do
      before(:each) {
        Chef::DataBag.stub(:load).and_return(data_bag)
        Chef::DataBagItem.stub(:load).and_return(item)
        item.stub(:save)
      }

      it "loads data bag item from Chef" do
        Chef::DataBag.should_receive(:load).with(data_bag_title).and_return(data_bag)
        Chef::DataBagItem.should_receive(:load).with(data_bag_title, item_title).and_return(item)
        subject.create_or_update_item(data_bag_title, item_title, value)
      end

      it "saves data bag item" do
        item.should_receive(:save)
        subject.create_or_update_item(data_bag_title, item_title, value)
      end
    end

    context "if data bag item doesn't exist" do
      before(:each) {
        Chef::DataBag.stub(:load).and_return({})
      }

      it "creates new data bag item" do
        object = Chef::DataBagItem.new
        Chef::DataBagItem.stub(:new).and_return(object)
        object.should_receive(:save)
        subject.create_or_update_item(data_bag_title, item_title, value)
        expect(object['id']).to be_eql item_title
        expect(value.reject { |k,v| object[k] == v }).to be_empty
      end
    end
  end
end
