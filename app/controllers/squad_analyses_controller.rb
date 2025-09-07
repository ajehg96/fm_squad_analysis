# frozen_string_literal: true

class SquadAnalysesController < ApplicationController
  def new
    # Renders the upload form
  end

  def show
    @tactics = Tactic.includes(:tactic_roles).all
    session[:selected_tactic_id] = params[:tactic_id] if params[:tactic_id]
    tactic_id = session[:selected_tactic_id] || @tactics.first.id
    @selected_tactic = @tactics.find { |t| t.id == tactic_id.to_i }

    # All the complex logic is now contained within this single report object
    @report = SquadAnalysisReport.new(tactic: @selected_tactic)
  end

  def create
    handle_file_upload
    redirect_to(squad_analysis_path(:latest), notice: "Squad file was successfully uploaded and analyzed.")
  end

  private

  def handle_file_upload
    return unless params[:squad_file] && params[:snapshot_date]

    importer = DataImporter.new
    persister = SquadDataPersister.new
    squad_file_path = params[:squad_file].path
    snapshot_date = params[:snapshot_date]

    raw_squad = importer.import_squad(squad_file_path)
    processed_data = importer.process_squad_data(raw_squad)
    persister.persist(processed_squad_data: processed_data, snapshot_date: snapshot_date)
  end
end
