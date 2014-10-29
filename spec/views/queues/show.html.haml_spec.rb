require 'spec_helper'

RSpec.describe 'queues/show', type: :view do
  before(:each) do
    assign(:queue, instance_double('AWS::SQS::Queue', visible_messages: 0, invisible_messages: 0))
  end

  context 'when message is passed' do
    it 'shows message info' do
      assign(:message, instance_double('AWS::SQS::Message', receive_count: 0, body: 'message_body'))
      render
      expect(rendered).to match('Times received:')
      expect(rendered).to match('message_body')
    end
  end

  it "doesn't show message" do
    render
    expect(rendered).to_not match('Times received:')
  end
end
