# frozen_string_literal: true

class PlayersController < ApplicationController
  def show
    player = Player.find(params[:id])
    # Create an instance of our service to do all the calculations
    @progression = PlayerProgression.new(player)
  end
end
