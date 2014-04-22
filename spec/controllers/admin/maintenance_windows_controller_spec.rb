require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe Admin::MaintenanceWindowsController do

  # This should return the minimal set of attributes required to create a valid
  # Admin::MaintenanceWindow. As you add validations to Admin::MaintenanceWindow, be sure to
  # adjust the attributes here as well.
  let(:some_admin) { FactoryGirl.create :superadmin }
  let(:valid_attributes) { { "name" => "MyString", "description" => "MyDescription", "message" => "MyMessage", "user" => some_admin } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Admin::MaintenanceWindowsController. Be sure to keep this updated too.
  let(:valid_session) { { :user_id => some_admin.id } }

  describe "GET index" do
    it "assigns all admin_maintenance_windows as @admin_maintenance_windows" do
      maintenance_window = FactoryGirl.create(:admin_maintenance_window, user: some_admin)
      get :index, {}, valid_session
      expect(assigns(:admin_maintenance_windows)).to eq([maintenance_window])
    end
  end

  describe "GET new" do
    it "assigns a new admin_maintenance_window as @admin_maintenance_window" do
      get :new, {}, valid_session
      expect(assigns(:admin_maintenance_window)).to be_a_new(Admin::MaintenanceWindow)
    end
  end

  describe "GET edit" do
    it "assigns the requested admin_maintenance_window as @admin_maintenance_window" do
      maintenance_window = Admin::MaintenanceWindow.create! valid_attributes
      get :edit, {:id => maintenance_window.to_param}, valid_session
      expect(assigns(:admin_maintenance_window)).to eq(maintenance_window)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Admin::MaintenanceWindow" do
        expect {
          post :create, {:admin_maintenance_window => valid_attributes}, valid_session
        }.to change(Admin::MaintenanceWindow, :count).by(1)
      end

      it "assigns a newly created admin_maintenance_window as @admin_maintenance_window" do
        post :create, {:admin_maintenance_window => valid_attributes}, valid_session
        expect(assigns(:admin_maintenance_window)).to be_a(Admin::MaintenanceWindow)
        expect(assigns(:admin_maintenance_window)).to be_persisted
      end

      it "redirects to the created admin_maintenance_window" do
        post :create, {:admin_maintenance_window => valid_attributes}, valid_session
        expect(response).to redirect_to(admin_maintenance_windows_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved admin_maintenance_window as @admin_maintenance_window" do
        # Trigger the behavior that occurs when invalid params are submitted
        Admin::MaintenanceWindow.any_instance.stub(:save).and_return(false)
        post :create, {:admin_maintenance_window => { "name" => "invalid value" }}, valid_session
        expect(assigns(:admin_maintenance_window)).to be_a_new(Admin::MaintenanceWindow)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Admin::MaintenanceWindow.any_instance.stub(:save).and_return(false)
        post :create, {:admin_maintenance_window => { "name" => "invalid value" }}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested admin_maintenance_window" do
        maintenance_window = Admin::MaintenanceWindow.create! valid_attributes
        # Assuming there are no other admin_maintenance_windows in the database, this
        # specifies that the Admin::MaintenanceWindow created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Admin::MaintenanceWindow).to receive(:update).with({ "name" => "MyString" })
        put :update, {:id => maintenance_window.to_param, :admin_maintenance_window => { "name" => "MyString" }}, valid_session
      end

      it "assigns the requested admin_maintenance_window as @admin_maintenance_window" do
        maintenance_window = Admin::MaintenanceWindow.create! valid_attributes
        put :update, {:id => maintenance_window.to_param, :admin_maintenance_window => valid_attributes}, valid_session
        expect(assigns(:admin_maintenance_window)).to eq(maintenance_window)
      end

      it "redirects to the index of admin_maintenance_windows" do
        maintenance_window = Admin::MaintenanceWindow.create! valid_attributes
        put :update, {:id => maintenance_window.to_param, :admin_maintenance_window => valid_attributes}, valid_session
        expect(response).to redirect_to(admin_maintenance_windows_url)
      end
    end

    describe "with invalid params" do
      it "assigns the admin_maintenance_window as @admin_maintenance_window" do
        maintenance_window = Admin::MaintenanceWindow.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Admin::MaintenanceWindow.any_instance.stub(:save).and_return(false)
        put :update, {:id => maintenance_window.to_param, :admin_maintenance_window => { "name" => "invalid value" }}, valid_session
        expect(assigns(:admin_maintenance_window)).to eq(maintenance_window)
      end

      it "re-renders the 'edit' template" do
        maintenance_window = Admin::MaintenanceWindow.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Admin::MaintenanceWindow.any_instance.stub(:save).and_return(false)
        put :update, {:id => maintenance_window.to_param, :admin_maintenance_window => { "name" => "invalid value" }}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

end
