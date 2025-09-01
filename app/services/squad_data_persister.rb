# frozen_string_literal: true

class SquadDataPersister
  def persist(processed_squad_data:, snapshot_date:)
    processed_squad_data.each do |player_hash|
      # Find the player by name, or create them if they don't exist
      player = Player.find_or_create_by!(name: player_hash["name"])

      # Create a new snapshot for this player with the uploaded data
      player.player_snapshots.create!(
        snapshot_date: snapshot_date,
        position_string: player_hash["position_string"],
        foot_right: player_hash["foot_right"],
        foot_left: player_hash["foot_left"],
        age: player_hash["age"],
        height: player_hash["height"],
        potential: player_hash["potential"],
        att_cor: player_hash["att_cor"],
        att_cro: player_hash["att_cro"],
        att_dri: player_hash["att_dri"],
        att_fin: player_hash["att_fin"],
        att_fir: player_hash["att_fir"],
        att_fre: player_hash["att_fre"],
        att_hea: player_hash["att_hea"],
        att_lon: player_hash["att_lon"],
        att_lth: player_hash["att_lth"],
        att_mar: player_hash["att_mar"],
        att_pas: player_hash["att_pas"],
        att_pen: player_hash["att_pen"],
        att_tck: player_hash["att_tck"],
        att_tec: player_hash["att_tec"],
        att_agg: player_hash["att_agg"],
        att_ant: player_hash["att_ant"],
        att_bra: player_hash["att_bra"],
        att_cmp: player_hash["att_cmp"],
        att_cnt: player_hash["att_cnt"],
        att_dec: player_hash["att_dec"],
        att_det: player_hash["att_det"],
        att_fla: player_hash["att_fla"],
        att_ldr: player_hash["att_ldr"],
        att_otb: player_hash["att_otb"],
        att_pos: player_hash["att_pos"],
        att_tea: player_hash["att_tea"],
        att_vis: player_hash["att_vis"],
        att_wor: player_hash["att_wor"],
        att_acc: player_hash["att_acc"],
        att_agi: player_hash["att_agi"],
        att_bal: player_hash["att_bal"],
        att_jum: player_hash["att_jum"],
        att_nat: player_hash["att_nat"],
        att_pac: player_hash["att_pac"],
        att_sta: player_hash["att_sta"],
        att_str: player_hash["att_str"],
        att_aer: player_hash["att_aer"],
        att_cmd: player_hash["att_cmd"],
        att_com: player_hash["att_com"],
        att_ecc: player_hash["att_ecc"],
        att_han: player_hash["att_han"],
        att_kic: player_hash["att_kic"],
        att_1v1: player_hash["att_1v1"],
        att_pun: player_hash["att_pun"],
        att_ref: player_hash["att_ref"],
        att_tro: player_hash["att_tro"],
        att_thr: player_hash["att_thr"],
      )
    end
  end
end
