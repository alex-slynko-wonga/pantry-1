require 'spec_helper'

describe LdapUsersController do
  context "#index" do
    let(:name) { "Alex" }
    let(:username) { 'alex' }
    let(:record) { {'samaccountname' => [username], 'displayname' => [name]} }
    it "returns LdapResource result" do
      resource = double
      expect(LdapResource).to receive(:new).and_return(resource)
      expect(resource).to receive(:find_user_by_name).with(name + "*").and_return([record])
      get :index, { term: name, format: :json }
      result = JSON.parse(response.body).first
      expect({ 'value' => username, 'label' => name }.reject { |k,v| result[k] == v }).to be_empty
    end
  end
end
