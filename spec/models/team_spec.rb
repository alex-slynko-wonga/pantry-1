RSpec.describe Team, type: :model do
  subject { FactoryGirl.build(:team) }

  describe 'without_jenkins' do
    it 'finds team without jenkins server' do
      FactoryGirl.create(:team)
      FactoryGirl.create(:jenkins_server)
      expect(Team.count).to eq(2)
      expect(Team.without_jenkins.count).to eq(1)
    end

    it 'finds team with terminated jenkins_server' do
      FactoryGirl.create(:jenkins_server, :terminated, team: subject)
      expect(Team.without_jenkins.count).to eq(1)
    end

    it 'skips team with terminated and running jenkins_server' do
      FactoryGirl.create(:jenkins_server, :terminated, team: subject)
      FactoryGirl.create(:jenkins_server, team: subject)
      expect(Team.without_jenkins.count).to eq(0)
    end
  end
end
