# frozen_string_literal: true

class TacticsController < ApplicationController
  before_action :set_tactic, only: [:show, :edit, :update, :destroy]

  def index
    @tactics = Tactic.includes(:tactic_roles).all
  end

  def show; end

  def new
    @tactic = Tactic.new
    11.times { |i| @tactic.tactic_roles.build(position: i + 1) }
  end

  def edit; end

  def create
    @tactic = Tactic.new(tactic_params)

    if @tactic.save
      redirect_to(@tactic, notice: "Tactic was successfully created.")
    else
      # Use the new status symbol here
      render(:new, status: :unprocessable_content)
    end
  end

  def update
    if @tactic.update(tactic_params)
      redirect_to(@tactic, notice: "Tactic was successfully updated.")
    else
      # And use the new status symbol here
      render(:edit, status: :unprocessable_content)
    end
  end

  def destroy
    @tactic.destroy
    redirect_to(tactics_url, notice: "Tactic was successfully destroyed.")
  end

  private

  def set_tactic
    @tactic = Tactic.find(params[:id])
  end

  def tactic_params
    params.require(:tactic).permit(:name, :description, tactic_roles_attributes: [:id, :position, :role])
  end
end
