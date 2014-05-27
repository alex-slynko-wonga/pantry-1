require 'spec_helper'

describe Admin::AmisController do
  before(:each) do
    session[:user_id] = user.id
  end

  context "user is not a superadmin" do
    let(:user) { FactoryGirl.create :user }

    it "returns a 404 status" do
      %w{ index new }.each do |action|
        get action
        expect(response.status).to eq 404
      end
    end
  end

  context "user is a superadmin" do
    let(:user) { FactoryGirl.create :superadmin }


    describe "POST 'create'" do
      it "creates a new ami" do
        expect { post 'create', ami_id: "ami-00000001",
                                name: "windows_sdk_server",
                                hidden: true,
                                platform: 'linux',
                                format: :json }.to change(Ami, :count).by(1)
      end
    end

    describe "PUT 'update'" do
      before(:each) do
        @ami = FactoryGirl.create(:ami)
      end

      it "updates an ami" do
        post 'update', id: @ami.ami_id, name: "windows_sdk_server", hidden: true, :format => :json
        expect(response).to be_success
      end

      it "changes the name and hidden attributes" do
        post 'update', id: @ami.ami_id, name: "windows_sdk_server", hidden: true, :format => :json
        expect(@ami.reload.name).to eq "windows_sdk_server"
      end
    end

    describe "DELETE 'destroy'" do
      it "deletes an ami" do
        ami = FactoryGirl.create(:ami)
        expect { delete 'destroy', id: ami }.to change(Ami, :count).by(-1)
      end
    end

    describe "GET 'edit'" do
      it "shoe be a success" do
        ami = FactoryGirl.create(:ami)
        get 'edit', id: ami
        expect(response).to be_success
      end
    end

    describe "GET 'show'" do
      it "shoe be a success" do
        ami = FactoryGirl.create(:ami)
        get 'show', id: ami, format: 'json'
        expect(response).to be_success
      end
    end
  end
end
