class Wonga::Pantry::Costs
  attr_reader :bill_date

  def initialize(bill_date)
    @bill_date = (bill_date || Date.today.end_of_month).to_date
  end

  def costs_per_team
    # TODO: check this in Rails4
    result = Team.joins('LEFT OUTER JOIN ec2_instances ON ec2_instances.team_id = teams.id').
      joins("LEFT OUTER JOIN ec2_instance_costs ON ec2_instance_costs.ec2_instance_id = ec2_instances.id AND ec2_instance_costs.bill_date = '#{@bill_date}'").
      where(ec2_instance_costs: { bill_date: [@bill_date, nil] }).
      select('teams.id, teams.name, SUM(ec2_instance_costs.cost) as costs').
      group('teams.id, teams.name').all

    result.map do |record|
      attributes = record.attributes
      attributes['costs'] ||= BigDecimal(0)
      attributes
    end
  end
end

