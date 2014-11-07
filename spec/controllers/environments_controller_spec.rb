RSpec.describe EnvironmentsController, type: :controller do
  let(:team) { FactoryGirl.create(:team) }
  let(:user) { User.new(role: 'developer', teams: [team]) }
  let(:chef_utility) { instance_double('Wonga::Pantry::ChefUtility').as_null_object }
  let(:environment) { FactoryGirl.create(:environment) }

  before :each do
    allow(Wonga::Pantry::ChefUtility).to receive(:new).and_return(chef_utility)
  end

  before(:each) do
    allow(@controller).to receive(:current_user).and_return(user)
  end

  describe "GET 'new'" do
    it 'should be a success' do
      get :new, team_id: team.id
      expect(response).to be_success
    end
  end

  describe "POST 'create'" do
    it 'should create a new environment' do
      expect do
        post :create,
             team_id: team.id,
             environment: {
               name: 'Env 1',
               description: 'Something',
               chef_environment: 'env1',
               environment_type: 'INT'
             }
      end.to change { Environment.count }.by(1)
    end

    it 'does not redirect if there is a validation error' do
      post :create, team_id: team.id,
                    environment: { environment_type: 'INT' }
      expect(response.status).not_to be eq(302)
    end
  end

  describe "GET 'show'" do
    it 'returns http success' do
      get 'show', id: environment.id
      expect(response).to be_success
    end
  end

  describe "PUT 'update'" do
    let(:environment_update_parameters) do
      { environment: FactoryGirl.attributes_for(:environment, name: 'EnvironmentTestName', description: 'Test Description') }.merge(id: environment.id)
    end

    before(:each) do
      allow(controller).to receive(:authorize)
    end

    it 'returns http success' do
      put 'update', environment_update_parameters
      expect(response).to be_redirect
    end

    it 'should update an environment' do
      put 'update', environment_update_parameters
      environment.reload
      expect(environment.name).to eq('EnvironmentTestName')
      expect(environment.description).to eq('Test Description')
    end
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get 'index', team_id: team.id
      expect(response).to be_success
    end
  end

  describe "PUT 'hide'" do
    let(:user) { User.new(role: 'superadmin', teams: [team]) }

    describe 'without instances' do
      let(:environment_hide_parameters) do
        { environment: FactoryGirl.attributes_for(:environment, hidden: true) }.merge(id: environment.id)
      end

      it 'returns http success' do
        put 'hide', environment_hide_parameters
        expect(response).to be_redirect
      end
    end

    describe 'with non-terminated instance' do
      let(:instance) { FactoryGirl.create(:ec2_instance, state: 'booting') }
      let(:environment_hide_parameters) do
        { environment: FactoryGirl.attributes_for(:environment, hidden: true) }.merge(id: environment.id)
      end

      it 'should not hide environment in non-terminated machine found' do
        environment.ec2_instances = [instance]
        put 'hide', environment_hide_parameters
        expect(flash[:error]).to match('Environment can not be hidden due to non-terminated instances')
        expect(environment.hidden).not_to eq(true)
        expect(response).to be_redirect
      end
    end
  end
end
