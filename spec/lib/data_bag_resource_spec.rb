require 'spec_helper'

describe DataBagResource do
  let(:data_bag_title) { 'DataBag' }
  let(:item_title) { 'DataBagItem' }
  let(:value) { { 'version' => 'test', 'name' => 'test' } }

  describe "#create_or_update_item" do
    let!(:data_bag) do
      bag = Chef::DataBag.new
      bag.name(data_bag_title)
      bag.create
    end

    let(:data_item) { Chef::DataBagItem.load(data_bag_title, item_title) }

    after(:each) { data_bag.destroy }

    context "if data bag exist" do
      before(:each) {
        item = Chef::DataBagItem.new
        item['id'] = item_title
        item.data_bag(data_bag_title)
        item.create
      }

      it "saves data bag item" do
        subject.create_or_update_item(data_bag_title, item_title, value)
        value.each do |key, value|
          expect(data_item[key]).to be_eql value
        end
      end
    end

    context "if data bag item doesn't exist" do
      it "creates new data bag item" do
        subject.create_or_update_item(data_bag_title, item_title, value)
        expect(data_item).to be_present
        expect(data_item['id']).to be_eql item_title
        value.each do |key, value|
          expect(data_item[key]).to be_eql value
        end
      end
    end
  end
end
