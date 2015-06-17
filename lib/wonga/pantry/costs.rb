class Wonga::Pantry::Costs
  attr_reader :bill_date

  def initialize(bill_date)
    @bill_date = (bill_date || Time.zone.today.end_of_month).to_date
  end

  def costs_per_team
    Team.joins(:ec2_instance_costs)
      .where(ec2_instance_costs: { bill_date: @bill_date })
      .select('teams.id, teams.name, SUM(ec2_instance_costs.cost) as costs, teams.disabled')
      .order('teams.name')
      .group('teams.id, teams.name').to_a
  end

  def costs_details_per_team(team_id)
    Ec2InstanceCost.includes(:ec2_instance)
      .where(ec2_instance_costs: { bill_date: @bill_date }, ec2_instances: { team_id: team_id })
      .order('ec2_instances.name').to_a
  end

  def costs_details
    Ec2InstanceCost.includes(:ec2_instance).where(ec2_instance_costs: { bill_date: @bill_date }).to_a
  end
end
