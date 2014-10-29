class QueuesController < ApplicationController
  def index
    @queues = AWS::SQS.new.queues.with_prefix(CONFIG['aws']['queue_prefix']).to_a
  end

  def show
    @queue = AWS::SQS.new.queues.with_prefix(CONFIG['aws']['queue_prefix']).named(params[:id])
    render(text: '404 Not Found', status: 404) && return unless @queue.url
    @message = @queue.receive_message if @queue.visible_messages > 0
  end
end
