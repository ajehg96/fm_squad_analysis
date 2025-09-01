# frozen_string_literal: true

class SquadAnalysesController < ApplicationController
  def new
    # Renders the upload form
  end

  def show
    load_and_analyze_data
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

  def load_and_analyze_data
    most_recent_date = PlayerSnapshot.maximum(:snapshot_date)
    unless most_recent_date
      @first_team = []
      return
    end

    importer = DataImporter.new
    recent_snapshots = PlayerSnapshot.where(snapshot_date: most_recent_date).includes(:player)

    # --- DEBUGGING STEP 1 ---
    puts "----------- DATA FROM DATABASE (BEFORE PROCESSING) -----------"
    pp(recent_snapshots.first)
    # ----------------------------------------------------------------

    squad_data = importer.process_database_snapshots(recent_snapshots)

    # --- DEBUGGING STEP 2 ---
    puts "----------- DATA AFTER PROCESSING (SHOULD HAVE BOOLEANS) -----------"
    pp(squad_data.first)
    # -----------------------------------------------------------------------

    attributes_file_path = Rails.root.join("data/role_attributes.csv")
    raw_attributes = importer.import_role_attributes(attributes_file_path)
    role_attributes = importer.process_role_attributes(raw_attributes)

    tactic = [
      { "position" => "gk_sk_d_c", "number" => 1 },
      { "position" => "cd_bpd_d_c", "number" => 2 },
      { "position" => "wb_wb_a_r", "number" => 1 },
      { "position" => "dm_sv_a_c", "number" => 1 },
      { "position" => "wb_wb_a_l", "number" => 1 },
      { "position" => "w_if_a_ri", "number" => 1 },
      { "position" => "w_if_a_li", "number" => 1 },
      { "position" => "s_af_a_c", "number" => 1 },
    ]

    role_ratings = importer.calculate_role_ratings(squad_data, role_attributes)
    assigner = TeamAssigner.new

    @first_team = assigner.assign_first_team(role_ratings, tactic)
    @second_team = assigner.assign_second_team(role_ratings, tactic, @first_team)
    @third_team = assigner.assign_third_team(role_ratings, tactic, @first_team, @second_team)
    @remainder = assigner.assign_best_roles_for_remainder(role_ratings, @first_team, @second_team, @third_team)
  end
end
