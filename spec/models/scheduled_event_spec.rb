RSpec.describe ScheduledEvent, type: :model do
  context '#ready_for_shutdown' do
    let(:time) { Time.now }
    it 'returns events for ready instances' do
      event = FactoryGirl.create(:scheduled_shutdown_event)
      expect(ScheduledEvent.ready_for_shutdown.first).to eq(event)
    end

    it 'returns shutdown events that occur in next 10 minutes' do
      event = FactoryGirl.create(:scheduled_shutdown_event, event_time: time + 9.minutes)
      expect(ScheduledEvent.ready_for_shutdown(time).first).to eq(event)
    end

    it 'returns events that were missed' do
      event = FactoryGirl.create(:scheduled_shutdown_event, event_time: time - 14.days)
      expect(ScheduledEvent.ready_for_shutdown(time).first).to eq(event)
    end

    it 'does not return events for in far future' do
      FactoryGirl.create(:scheduled_shutdown_event, event_time: time + 1.hours)
      expect(ScheduledEvent.ready_for_shutdown(time)).to be_empty
    end
  end
end
