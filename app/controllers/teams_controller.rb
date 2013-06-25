class TeamsController < ApplicationController
  def create
  end

  def index
  	@teams = Team.all
  end

  def show
  end

  def update
  end
end
