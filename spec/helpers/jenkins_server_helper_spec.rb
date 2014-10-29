require 'spec_helper'

RSpec.describe JenkinsServerHelper, type: :helper do
  describe 'link_to_new_slave' do
    before(:each) do
      allow(helper).to receive(:policy).and_return(policy)
    end

    context 'when user has access to create slave' do
      let(:policy) { instance_double(JenkinsSlavePolicy, create?: true) }

      it 'renders link' do
        expect(helper.link_to_new_slave(JenkinsServer.new(id: 1))).to match(/^<a/)
      end
    end

    context "when user can't create slave" do
      let(:policy) { instance_double(JenkinsSlavePolicy, create?: false)  }

      it 'renders nothing' do
        expect(helper.link_to_new_slave(JenkinsServer.new)).to be_nil
      end
    end
  end
end
