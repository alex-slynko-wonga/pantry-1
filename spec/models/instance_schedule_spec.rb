RSpec.describe InstanceSchedule, type: :model do
  it 'sets next event for ec2_instance when assigned' do
    instance = FactoryGirl.build(:ec2_instance, :running)
    schedule = FactoryGirl.build(:instance_schedule, ec2_instance: instance)
    expect(instance.scheduled_event).to eq nil
    schedule.valid?
    expect(instance.scheduled_event).not_to eq nil
  end

  describe '#next_start_time' do
    before(:each) do
      Timecop.travel time
    end

    context 'for weekend only shutdown' do
      let(:time) do
        t = Time.current
        t += (5 - t.wday).days
        t.change(hour: hour, min: 0)
      end

      let(:hour) { planned_hour - 2 }
      let(:planned_hour) { 12 }
      subject { FactoryGirl.build(:instance_schedule, start_time: Time.current.change(hour: planned_hour, min: 0), weekend_only: true) }

      it 'is on planned time' do
        start_time = subject.next_start_time
        expect(start_time.hour).to eq planned_hour
        expect(start_time.min).to eq 0
      end

      it 'is next Monday' do
        start_time = subject.next_start_time
        next_monday = time + 3.days
        expect(start_time.day).to eq next_monday.day
        expect(start_time.month).to eq next_monday.month
        expect(start_time.year).to eq next_monday.year
      end

      context 'if today is Saturday' do
        let(:time) do
          t = Time.current
          t += (6 - t.wday).days
          t.change(hour: hour, min: 0)
        end

        it 'is next Monday' do
          start_time = subject.next_start_time
          next_monday = time + 2.days
          expect(start_time.day).to eq next_monday.day
          expect(start_time.month).to eq next_monday.month
          expect(start_time.year).to eq next_monday.year
        end
      end

      context 'if today is Saturday before Daylight Saving Time' do
        subject { FactoryGirl.create(:instance_schedule, start_time: Time.current.change(hour: planned_hour, min: 0), weekend_only: true).reload }
        let(:time) { Time.current.change(year: 2015, month: 3, day: 28, hour: hour) }

        it 'is on planned time' do
          start_time = subject.next_start_time
          expect(start_time.in_time_zone.hour).to eq planned_hour
          expect(start_time.min).to eq 0
        end
      end

      context 'if today is Monday' do
        let(:time) do
          t = Time.current
          t += (1 - t.wday).days
          t.change(hour: hour, min: 0)
        end

        context 'if it later than planned time' do
          let(:hour) { planned_hour + 1 }

          it 'is next Monday' do
            start_time = subject.next_start_time
            next_monday = time + 1.week
            expect(start_time.day).to eq next_monday.day
            expect(start_time.month).to eq next_monday.month
            expect(start_time.year).to eq next_monday.year
          end
        end

        it 'is today' do
          expect(subject.next_start_time).to be_today
        end
      end
    end

    context 'for every day' do
      let(:time) do
        t = Time.current
        t += (2 - t.wday).days
        t.change(hour: hour, min: 0)
      end

      let(:hour) { planned_hour - 2 }
      let(:planned_hour) { 12 }
      subject { FactoryGirl.build(:instance_schedule, start_time: Time.current.change(hour: planned_hour, min: 0)) }

      it 'is on planned time' do
        start_time = subject.next_start_time
        expect(start_time.hour).to eq planned_hour
        expect(start_time.min).to eq 0
      end

      context 'if it later than planned time' do
        let(:hour) { planned_hour + 1 }

        it 'is on planned time' do
          start_time = subject.next_start_time
          expect(start_time.hour).to eq planned_hour
          expect(start_time.min).to eq 0
        end

        it 'is tomorrow' do
          start_time = subject.next_start_time
          tomorrow = time + 1.day
          expect(start_time.day).to eq tomorrow.day
          expect(start_time.month).to eq tomorrow.month
          expect(start_time.year).to eq tomorrow.year
        end
      end

      it 'is today' do
        expect(subject.next_start_time).to be_today
      end

      context 'if today is Saturday' do
        let(:time) do
          t = Time.current
          t += (6 - t.wday).days
          t.change(hour: hour, min: 0)
        end

        it 'is next Monday' do
          start_time = subject.next_start_time
          next_monday = time + 2.days
          expect(start_time.day).to eq next_monday.day
          expect(start_time.month).to eq next_monday.month
          expect(start_time.year).to eq next_monday.year
        end
      end
    end
  end

  describe '#next_shutdown_time' do
    before(:each) do
      Timecop.travel time
    end

    context 'for weekend only shutdown' do
      let(:time) do
        t = Time.current
        t += (2 - t.wday).days
        t.change(hour: hour, min: 0)
      end

      let(:hour) { planned_hour - 2 }
      let(:planned_hour) { 12 }
      subject { FactoryGirl.build(:instance_schedule, shutdown_time: Time.current.change(hour: planned_hour, min: 0), weekend_only: true) }

      it 'is on planned time' do
        shutdown_time = subject.next_shutdown_time
        expect(shutdown_time.hour).to eq planned_hour
        expect(shutdown_time.min).to eq 0
      end

      it 'is next Friday' do
        shutdown_time = subject.next_shutdown_time
        next_friday = time + 3.days
        expect(shutdown_time.day).to eq next_friday.day
        expect(shutdown_time.month).to eq next_friday.month
        expect(shutdown_time.year).to eq next_friday.year
      end

      context 'if today is Friday' do
        let(:time) do
          t = Time.current
          t += (5 - t.wday).days
          t.change(hour: hour, min: 0)
        end

        context 'if it later than planned time' do
          let(:hour) { planned_hour + 1 }

          it 'is next Friday' do
            shutdown_time = subject.next_shutdown_time
            next_friday = time + 1.week
            expect(shutdown_time.day).to eq next_friday.day
            expect(shutdown_time.month).to eq next_friday.month
            expect(shutdown_time.year).to eq next_friday.year
          end
        end

        it 'is today' do
          expect(subject.next_shutdown_time).to be_today
        end
      end
    end

    context 'for every day' do
      let(:time) do
        t = Time.current
        t += (2 - t.wday).days
        t.change(hour: hour, min: 0)
      end

      let(:hour) { planned_hour - 2 }
      let(:planned_hour) { 12 }
      subject { FactoryGirl.build(:instance_schedule, shutdown_time: Time.current.change(hour: planned_hour, min: 0)) }

      it 'is on planned time' do
        shutdown_time = subject.next_shutdown_time
        expect(shutdown_time.hour).to eq planned_hour
        expect(shutdown_time.min).to eq 0
      end

      context 'if it later than planned time' do
        let(:hour) { planned_hour + 1 }

        it 'is on planned time' do
          shutdown_time = subject.next_shutdown_time
          expect(shutdown_time.hour).to eq planned_hour
          expect(shutdown_time.min).to eq 0
        end

        it 'is tomorrow' do
          shutdown_time = subject.next_shutdown_time
          tomorrow = time + 1.day
          expect(shutdown_time.day).to eq tomorrow.day
          expect(shutdown_time.month).to eq tomorrow.month
          expect(shutdown_time.year).to eq tomorrow.year
        end
      end

      it 'is today' do
        expect(subject.next_shutdown_time).to be_today
      end
    end
  end
end
