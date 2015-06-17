require 'spec_helper'
include Pundit

RSpec.describe TeamsHelper, type: :helper do
  describe '#os_image' do
    it 'displays the linux icon' do
      expect(helper.os_image(nil)).to include "src=\"/assets/linux_icon.png\""
    end

    it 'displays the windows icon' do
      expect(helper.os_image('windows')).to include "src=\"/assets/win_icon.png\""
    end
  end

  describe '#can_add_server?' do
    it 'is true when team has no jenkins server' do
      expect(helper).to be_can_add_server(Team.new)
    end

    it 'false when team has jenkins_server' do
      team = Team.new
      team.build_jenkins_server
      expect(helper).not_to be_can_add_server(team)
    end
  end

  describe '#teams_header' do
    context 'when params[:inactive] is true' do
      it "returns 'Inactive teams'" do
        expect(helper.teams_header(true)).to eq 'Inactive teams'
      end
    end

    context 'when params[:inactive] is false' do
      it "returns 'Teams' if " do
        expect(helper.teams_header(false)).to eq 'Teams'
      end
    end
  end

  describe '#teams_toggle_link' do
    before(:each) do
      allow(helper).to receive(:policy).and_return(policy)
    end
    context 'when user cannot see inactive teams' do
      let(:policy) { instance_double(TeamPolicy, see_inactive_teams?: true) }

      context 'when params[:inactive] is true' do
        it "returns link with 'show only active teams'" do
          expect(helper.teams_toggle_link(true)).to match(/show only active teams/)
        end
      end

      context 'when params[:inactive] is false' do
        it "returns link with 'show only inactive teams'" do
          expect(helper.teams_toggle_link(false)).to match(/show only inactive teams/)
        end
      end
    end

    context 'when user cannot see inactive teams' do
      let(:policy) { instance_double(TeamPolicy, see_inactive_teams?: false) }
      it { expect(helper.teams_toggle_link(true)).to be_nil }
    end
  end
end
