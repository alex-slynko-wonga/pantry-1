require 'spec_helper'

RSpec.describe Admin::MaintenanceWindowsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/maintenance_windows').to route_to('admin/maintenance_windows#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/maintenance_windows/new').to route_to('admin/maintenance_windows#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/maintenance_windows/1').to route_to('admin/maintenance_windows#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/maintenance_windows/1/edit').to route_to('admin/maintenance_windows#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/maintenance_windows').to route_to('admin/maintenance_windows#create')
    end

    it 'routes to #update' do
      expect(put: '/admin/maintenance_windows/1').to route_to('admin/maintenance_windows#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/maintenance_windows/1').to route_to('admin/maintenance_windows#destroy', id: '1')
    end
  end
end
