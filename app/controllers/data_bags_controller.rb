class DataBagsController < ApplicationController
  def index
    @data_bags = Chef::DataBag.list.keys
  end
end
