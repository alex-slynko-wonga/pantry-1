class Api::BillsController < ApiController

  def create
    date = Date.parse(params[:bill_date])
    bill = Bill.where(bill_date: date).first_or_initialize
    bill.update_attributes(total_cost: params[:total_cost].to_d)
    respond_with [:api, bill]
  end
end
