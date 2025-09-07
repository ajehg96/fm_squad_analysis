# frozen_string_literal: true

class PlayersController < ApplicationController
  def show
    player = Player.find(params[:id])
    tactic_id = session[:selected_tactic_id]
    tactic = Tactic.find(tactic_id) if tactic_id
    # Create an instance of our service to do all the calculations
    @progression = PlayerProgression.new(player, tactic: tactic)
  end
end
