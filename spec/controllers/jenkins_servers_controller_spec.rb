RSpec.describe JenkinsServersController, type: :controller do
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:team) { FactoryGirl.create(:team, :with_ci_environment) }

  before(:each) do
    session[:user_id] = user.id
  end

  describe 'index' do
    it 'returns http success' do
      get 'index'
      expect(response).to be_success
    end

    it 'should assign a server if there is only one team' do
      FactoryGirl.create(:jenkins_server, team: user.teams.first)
      expect(user.teams.count).to be 1
      get 'index'
      expect(assigns(:jenkins_servers).count).to be 1
    end
  end

  describe "GET 'new'" do
    it 'returns http success' do
      get 'new'
      expect(response).to be_success
    end

    describe 'when user has no teams without jenkins server' do
      let(:user) { FactoryGirl.create(:user) }

      it 'redirects to index page' do
        get 'new'
        expect(response).to be_redirect
      end

      it 'notifies the user' do
        get 'new'
        expect(flash[:error]).to eq('You cannot create a server because you do not belong to this team')
      end
    end
  end

  describe "POST 'create'" do
    before(:each) do
      allow(Wonga::Pantry::JenkinsUtility).to receive(:new).and_return(jenkins_utility)
      allow(JenkinsServer).to receive(:new).and_return(JenkinsServer.new(id: 42, team_id: team.id))
    end

    context 'when JenkinsUtility process instance' do
      let(:jenkins_utility) { instance_double(Wonga::Pantry::JenkinsUtility, request_jenkins_instance: true) }

      it 'redirects to resource' do
        post :create, jenkins_server: { team_id: team.id }
        expect(response).to be_redirect
      end
    end

    context "when JenkinsUtility can't process instance" do
      let(:jenkins_utility) { instance_double(Wonga::Pantry::JenkinsUtility, request_jenkins_instance: false) }

      it 'renders new' do
        post :create, jenkins_server: { team_id: team.id }
        expect(response).to render_template('new')
      end

      it 'assigns the teams to the current user' do
        post :create, jenkins_server: { team_id: team.id }
        expect(assigns(:user_teams).size).to be 1
      end
    end

    context 'when someone has just created Jenkins Server' do
      let(:jenkins_utility) { instance_double(Wonga::Pantry::JenkinsUtility, request_jenkins_instance: false) }
      let(:team) { FactoryGirl.create(:team) }

      it 'redirects' do
        post :create, jenkins_server: { team_id: team.id }
        expect(response).to be_redirect
      end
    end
  end
end
