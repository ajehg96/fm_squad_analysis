# frozen_string_literal: true

require "ostruct"

# This service calculates all the data needed for a player's progression page.
class PlayerProgression
  attr_reader :player

  # Define the attribute groups
  TECHNICAL_ATTRS = [:att_cor, :att_cro, :att_dri, :att_fin, :att_fir, :att_fre, :att_hea, :att_lon, :att_lth, :att_mar, :att_pas, :att_pen, :att_tck, :att_tec].freeze
  MENTAL_ATTRS = [:att_agg, :att_ant, :att_bra, :att_cmp, :att_cnt, :att_dec, :att_det, :att_fla, :att_ldr, :att_otb, :att_pos, :att_tea, :att_vis, :att_wor].freeze
  PHYSICAL_ATTRS = [:att_acc, :att_agi, :att_bal, :att_jum, :att_nat, :att_pac, :att_sta, :att_str].freeze
  GOALKEEPING_ATTRS = [:att_aer, :att_cmd, :att_com, :att_ecc, :att_han, :att_kic, :att_1v1, :att_pun, :att_ref, :att_tro, :att_thr].freeze

  def initialize(player, tactic: nil)
    @player = player
    @snapshots = player.player_snapshots.order(snapshot_date: :asc)
    @tactic = tactic
  end

  def goalkeeper?
    current_snapshot.position_string&.include?("GK")
  end

  def joined_date
    first_snapshot&.snapshot_date
  end

  def role_ratings
    importer = DataImporter.new
    squad_data = importer.process_database_snapshots([current_snapshot])
    # Use our new RoleData service instead of reading the file here
    importer.calculate_role_ratings(squad_data, role_attributes).first
  end

  def role_attributes
    all_roles = RoleData.all_roles

    if @tactic
      tactic_role_codes = @tactic.tactic_roles.pluck(:role)
      all_roles.select { |role| tactic_role_codes.include?(role.role_code) }
    else
      all_roles
    end
  end

  # Public methods for each attribute group
  def technical_attributes
    calculate_changes_for(TECHNICAL_ATTRS)
  end

  def mental_attributes
    calculate_changes_for(MENTAL_ATTRS)
  end

  def physical_attributes
    calculate_changes_for(PHYSICAL_ATTRS)
  end

  def goalkeeping_attributes
    calculate_changes_for(GOALKEEPING_ATTRS)
  end

  private

  def current_snapshot
    @current_snapshot ||= @snapshots.last || OpenStruct.new
  end

  def previous_snapshot
    @previous_snapshot ||= @snapshots.length > 1 ? @snapshots[-2] : first_snapshot
  end

  def first_snapshot
    @first_snapshot ||= @snapshots.first || OpenStruct.new
  end

  # Central calculation logic to avoid repetition
  def calculate_changes_for(attribute_keys)
    attribute_keys.to_h do |attr_key|
      attr_str = attr_key.to_s
      current_value = current_snapshot[attr_str].to_i
      previous_value = previous_snapshot[attr_str].to_i
      first_value = first_snapshot[attr_str].to_i

      changes = {
        current_value: current_value,
        change_since_previous: current_value - previous_value,
        change_since_first: current_value - first_value,
      }
      [attr_key, changes]
    end
  end
end
