# frozen_string_literal: true

module SquadsHelper
  def position_sort_order
    {
      "gk" => 0,
      "cd" => 1,
      "fb" => 2,
      "wb" => 3,
      "dm" => 4,
      "cm" => 5,
      "wm" => 6,
      "am" => 7,
      "w" => 8,
      "s" => 9,
    }
  end

  def sort_by_position(players)
    players.sort_by do |player|
      role_code = player[:position]
      position_group = role_code.split("_").first
      side_code = role_code.split("_").last

      side_order = case side_code
      when "l", "li" then 0
      when "c" then 1
      when "r", "ri" then 2
      else 3
      end

      [position_sort_order[position_group], side_order, role_code]
    end
  end

  def position_coordinates(position_code)
    coordinates = {
      # Goalkeepers
      "gk_gk_d_c" => { x: 50, y: 95 },
      "gk_sk_d_c" => { x: 50, y: 95 },
      "gk_sk_s_c" => { x: 50, y: 90 },
      "gk_sk_a_c" => { x: 50, y: 85 },

      # Defenders
      "cd_nncb_d_c" => { x: 50, y: 80 },
      "cd_cd_d_c" => { x: 50, y: 80 },
      "cd_bpd_d_c" => { x: 50, y: 80 },
      "cd_l_s_c" => { x: 50, y: 75 },
      "cd_l_a_c" => { x: 50, y: 70 },
      "cd_wcb_d_c" => { x: 35, y: 78 },
      "cd_wcb_s_c" => { x: 35, y: 75 },
      "cd_wcb_a_c" => { x: 35, y: 72 },

      "fb_nnfb_d_r" => { x: 85, y: 75 },
      "fb_fb_d_r" => { x: 85, y: 75 },
      "fb_fb_s_r" => { x: 85, y: 70 },
      "fb_fb_a_r" => { x: 85, y: 65 },
      "fb_wb_d_r" => { x: 90, y: 70 },
      "fb_wb_s_r" => { x: 90, y: 65 },
      "fb_wb_a_r" => { x: 90, y: 60 },
      "fb_iwb_d_ri" => { x: 75, y: 65 },
      "fb_iwb_s_ri" => { x: 75, y: 60 },
      "fb_iwb_a_ri" => { x: 75, y: 55 },
      "fb_cwb_s_r" => { x: 90, y: 60 },
      "fb_cwb_a_r" => { x: 90, y: 55 },

      "fb_nnfb_d_l" => { x: 15, y: 75 },
      "fb_fb_d_l" => { x: 15, y: 75 },
      "fb_fb_s_l" => { x: 15, y: 70 },
      "fb_fb_a_l" => { x: 15, y: 65 },
      "fb_wb_d_l" => { x: 10, y: 70 },
      "fb_wb_s_l" => { x: 10, y: 65 },
      "fb_wb_a_l" => { x: 10, y: 60 },
      "fb_iwb_d_li" => { x: 25, y: 65 },
      "fb_iwb_s_li" => { x: 25, y: 60 },
      "fb_iwb_a_li" => { x: 25, y: 55 },
      "fb_cwb_s_l" => { x: 10, y: 60 },
      "fb_cwb_a_l" => { x: 10, y: 55 },

      # Wing Backs
      "wb_wb_d_r" => { x: 90, y: 70 },
      "wb_wb_s_r" => { x: 90, y: 65 },
      "wb_wb_a_r" => { x: 90, y: 60 },
      "wb_iwb_d_ri" => { x: 80, y: 65 },
      "wb_iwb_s_ri" => { x: 80, y: 60 },
      "wb_iwb_a_ri" => { x: 80, y: 55 },
      "wb_cwb_s_r" => { x: 90, y: 60 },
      "wb_cwb_a_r" => { x: 90, y: 55 },
      "wb_wb_d_l" => { x: 10, y: 70 },
      "wb_wb_s_l" => { x: 10, y: 65 },
      "wb_wb_a_l" => { x: 10, y: 60 },
      "wb_iwb_d_li" => { x: 20, y: 65 },
      "wb_iwb_s_li" => { x: 20, y: 60 },
      "wb_iwb_a_li" => { x: 20, y: 55 },
      "wb_cwb_s_l" => { x: 10, y: 60 },
      "wb_cwb_a_l" => { x: 10, y: 55 },

      # Defensive Midfielders
      "dm_a_d_c" => { x: 50, y: 60 },
      "dm_dlp_d_c" => { x: 50, y: 60 },
      "dm_dm_d_c" => { x: 50, y: 60 },
      "dm_bwm_d_c" => { x: 50, y: 60 },
      "dm_hb_d_c" => { x: 50, y: 65 },
      "dm_dlp_s_c" => { x: 50, y: 55 },
      "dm_r_s_c" => { x: 50, y: 55 },
      "dm_dm_s_c" => { x: 50, y: 55 },
      "dm_bwm_s_c" => { x: 50, y: 55 },
      "dm_sv_s_c" => { x: 60, y: 55 },
      "dm_sv_a_c" => { x: 60, y: 50 },
      "dm_rp_s_c" => { x: 50, y: 55 },

      # Midfielders
      "cm_rp_s_c" => { x: 50, y: 45 },
      "cm_bwm_d_c" => { x: 50, y: 45 },
      "cm_bwm_s_c" => { x: 50, y: 45 },
      "cm_dlp_d_c" => { x: 50, y: 45 },
      "cm_dlp_s_c" => { x: 50, y: 45 },
      "cm_c_s_c" => { x: 50, y: 45 },
      "cm_cm_d_c" => { x: 50, y: 45 },
      "cm_cm_s_c" => { x: 50, y: 45 },
      "cm_cm_a_c" => { x: 50, y: 40 },
      "cm_btbm_s_c" => { x: 50, y: 40 },
      "cm_m_s_c" => { x: 60, y: 40 },
      "cm_m_a_c" => { x: 60, y: 35 },
      "cm_ap_s_c" => { x: 50, y: 35 },
      "cm_ap_a_c" => { x: 50, y: 30 },

      # Wide Midfielders
      "wm_w_s_r" => { x: 85, y: 40 },
      "wm_w_a_r" => { x: 85, y: 35 },
      "wm_dw_d_r" => { x: 85, y: 45 },
      "wm_dw_s_r" => { x: 85, y: 40 },
      "wm_wm_d_r" => { x: 85, y: 45 },
      "wm_wm_s_r" => { x: 85, y: 40 },
      "wm_wm_a_r" => { x: 85, y: 35 },
      "wm_iw_s_ri" => { x: 75, y: 35 },
      "wm_iw_a_ri" => { x: 75, y: 30 },
      "wm_wp_s_r" => { x: 85, y: 35 },
      "wm_wp_a_r" => { x: 85, y: 30 },
      "wm_w_s_l" => { x: 15, y: 40 },
      "wm_w_a_l" => { x: 15, y: 35 },
      "wm_dw_d_l" => { x: 15, y: 45 },
      "wm_dw_s_l" => { x: 15, y: 40 },
      "wm_wm_d_l" => { x: 15, y: 45 },
      "wm_wm_s_l" => { x: 15, y: 40 },
      "wm_wm_a_l" => { x: 15, y: 35 },
      "wm_iw_s_li" => { x: 25, y: 35 },
      "wm_iw_a_li" => { x: 25, y: 30 },
      "wm_wp_s_l" => { x: 15, y: 35 },
      "wm_wp_a_l" => { x: 15, y: 30 },

      # Attacking Midfielders
      "am_ss_a_c" => { x: 50, y: 20 },
      "am_ap_s_c" => { x: 50, y: 25 },
      "am_ap_a_c" => { x: 50, y: 20 },
      "am_am_s_c" => { x: 50, y: 25 },
      "am_am_a_c" => { x: 50, y: 20 },
      "am_e_s_c" => { x: 50, y: 30 },
      "am_t_a_c" => { x: 50, y: 20 },

      # Wingers
      "w_w_s_r" => { x: 90, y: 20 },
      "w_w_a_r" => { x: 90, y: 15 },
      "w_if_s_ri" => { x: 80, y: 15 },
      "w_if_a_ri" => { x: 80, y: 10 },
      "w_iw_s_ri" => { x: 80, y: 15 },
      "w_iw_a_ri" => { x: 80, y: 10 },
      "w_r_a_r" => { x: 90, y: 15 },
      "w_wtf_s_r" => { x: 90, y: 15 },
      "w_wtf_a_r" => { x: 90, y: 10 },
      "w_ap_s_r" => { x: 90, y: 25 },
      "w_ap_a_r" => { x: 90, y: 20 },
      "w_t_a_r" => { x: 90, y: 15 },
      "w_w_s_l" => { x: 10, y: 20 },
      "w_w_a_l" => { x: 10, y: 15 },
      "w_if_s_li" => { x: 20, y: 15 },
      "w_if_a_li" => { x: 20, y: 10 },
      "w_iw_s_li" => { x: 20, y: 15 },
      "w_iw_a_li" => { x: 20, y: 10 },
      "w_r_a_l" => { x: 10, y: 15 },
      "w_wtf_s_l" => { x: 10, y: 15 },
      "w_wtf_a_l" => { x: 10, y: 10 },
      "w_ap_s_l" => { x: 10, y: 25 },
      "w_ap_a_l" => { x: 10, y: 20 },
      "w_t_a_l" => { x: 10, y: 15 },

      # Strikers
      "s_pf_d_c" => { x: 50, y: 15 },
      "s_pf_s_c" => { x: 50, y: 10 },
      "s_pf_a_c" => { x: 50, y: 5 },
      "s_af_a_c" => { x: 50, y: 5 },
      "s_tf_s_c" => { x: 50, y: 10 },
      "s_tf_a_c" => { x: 50, y: 5 },
      "s_dlf_s_c" => { x: 50, y: 15 },
      "s_dlf_a_c" => { x: 50, y: 10 },
      "s_p_a_c" => { x: 50, y: 5 },
      "s_fn_s_c" => { x: 50, y: 20 },
      "s_t_a_c" => { x: 50, y: 10 },
      "s_cf_s_c" => { x: 50, y: 12 },
      "s_cf_a_c" => { x: 50, y: 8 },
    }
    coordinates.default = { x: 50, y: 50 }
    coordinates[position_code]
  end

  def position_group(position_code)
    group = position_code.split("_").first
    if ["cd", "dm", "cm", "am", "s"].include?(group)
      return group
    end

    position_code
  end

  def adjusted_team_layout(team, offset_x = 12)
    grouped_by_position = team.group_by { |p| position_group(p[:position]) }
    adjusted_players = []

    grouped_by_position.each do |_, players|
      players.each_with_index do |player, index|
        base_coords = position_coordinates(player[:position])
        num_players = players.size

        if num_players > 1
          new_x = base_coords[:x] + (index - (num_players - 1) / 2.0) * offset_x
          adjusted_players << player.merge(coordinates: { x: new_x, y: base_coords[:y] })
        else
          adjusted_players << player.merge(coordinates: base_coords)
        end
      end
    end

    adjusted_players
  end

  def abbreviate_role(role_name, mentality)
    full_text = "#{role_name} - #{mentality}"
    return full_text if full_text.length <= 19

    abbreviation = role_name.split(" ").map(&:first).join
    "#{abbreviation} - #{mentality}"
  end

  def total_team_rating(team)
    team.sum { |player| player[:score] || 0 }.round(2)
  end
end
