require 'spec_helper'

describe TeamsController do
  let (:team) { FactoryGirl.create(:team) }

=begin
  describe "POST 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end
=end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show', :id => team.id
      response.should be_success
    end
  end

=begin
  describe "GET 'update'" do
    it "returns http success" do
      get 'update'
      response.should be_success
    end
  end
=end

end
