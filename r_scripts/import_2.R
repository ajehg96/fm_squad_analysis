library(data.table)
library(rlist)
library(plyr)
library(tidyverse)
library(XML)

setwd("C:/Users/AJEHG/OneDrive/Documents/R/footballManager")

##### Import Data #####

tacticRoles <- c("goal_keeper-sweeper_keeper-defend-centre",
                 "central_defender-ball_playing_defender-defend-centre",
                 "full_back-full_back-attack-right",
                 "full_back-full_back-attack-left",
                 "defensive_midfielder-defensive_midfielder-support-centre",
                 "winger-inside_forward-attack-right_inverted",
                 "winger-inside_forward-support-left_inverted",
                 "striker-advanced_forward-attack-centre",
                 "striker-pressing_forward-support-centre")

role_attributes <- fread("data/role_attributes.csv", na.strings=c("", "#NA")) %>%
  type.convert(as.is = TRUE) %>%
  rowwise() %>%
  mutate(role_code = paste0(paste0(str_split(role, "_", simplify = TRUE) %>%
                                     str_sub(1, 1), collapse = ""), "_",
                            str_sub(mentality, 1, 1), "_",
                            str_sub(side, 1, 1))) %>%
  filter(paste(position, role, mentality, side, sep = "-") %in% tacticRoles)

role_attributes[role_attributes == 0.1] <- 0

# role_attributes$role_code <- paste0(paste(str_split(role_attributes$role, "_", simplify = TRUE) %>%
#                                              str_sub(1, 1)), "_",
#                                     str_sub(role_attributes$mentality, 1, 1), "_",
#                                     str_sub(role_attributes$side, 1, 1))

squad <- htmlParse("data/squad.html", encoding = "UTF-8")
squad <- readHTMLTable(squad) %>%
  as.data.frame() %>%
  filter(!if_any(8:50, ~ str_detect(.x, "-"))) %>%
  select("name" = "NULL.Name", "age" = "NULL.Age", "height" = "NULL.Height", "position" = "NULL.Position",
         "foot_right" = "NULL.Right.Foot", "foot_left" = "NULL.Left.Foot", "att_cor" = "NULL.Cor",
         "att_cro" = "NULL.Cro", "att_dri" = "NULL.Dri", "att_fin" = "NULL.Fin", "att_fir" = "NULL.Fir",
         "att_fre" = "NULL.Fre", "att_hea" = "NULL.Hea", "att_lon" = "NULL.Lon", "att_lth" = "NULL.L.Th",
         "att_mar" = "NULL.Mar", "att_pas" = "NULL.Pas", "att_pen" = "NULL.Pen", "att_tck" = "NULL.Tck",
         "att_tec" = "NULL.Tec", "att_agg" = "NULL.Agg", "att_ant" = "NULL.Ant", "att_bra" = "NULL.Bra",
         "att_cmp" = "NULL.Cmp", "att_cnt" = "NULL.Cnt", "att_dec" = "NULL.Dec", "att_det" = "NULL.Det",
         "att_fla" = "NULL.Fla", "att_ldr" = "NULL.Ldr", "att_otb" = "NULL.OtB", "att_pos" = "NULL.Pos",
         "att_tea" = "NULL.Tea", "att_vis" = "NULL.Vis", "att_wor" = "NULL.Wor", "att_acc" = "NULL.Acc",
         "att_agi" = "NULL.Agi", "att_bal" = "NULL.Bal", "att_jum" = "NULL.Jum", "att_nat" = "NULL.Nat",
         "att_pac" = "NULL.Pac", "att_sta" = "NULL.Sta", "att_str" = "NULL.Str", "att_aer" = "NULL.Aer",
         "att_cmd" = "NULL.Cmd", "att_com" = "NULL.Com", "att_ecc" = "NULL.Ecc", "att_han" = "NULL.Han",
         "att_kic" = "NULL.Kic", "att_1v1" = "NULL.1v1", "att_pun" = "NULL.Pun", "att_ref" = "NULL.Ref",
         "att_tro" = "NULL.TRO", "att_thr" = "NULL.Thr") %>%
  mutate(height = str_remove(height, " cm")) %>%
  mutate(position = sub("([A-Z])([(])", "\\1 \\2", sub("([A-Z])([(])", "\\1 \\2", sub("([A-Z])([(])", "\\1 \\2", str_replace_all(str_replace_all(str_replace_all(position, "/", ","), " ", ""), ",", " "))))) %>%
  mutate(goal_keeper = str_detect(position, "GK"),
         full_back = str_detect(position, "(^D\\s|\\sD\\s)([\\w*\\s*])*(\\(\\w*[RL]\\w*\\)?)"),
         central_defender = str_detect(position, "(^D\\s|\\sD\\s)([\\w*\\s*])*(\\(\\w*[C]\\w*\\)?)"),
         wing_back = str_detect(position, "WB"),
         defensive_midfielder = str_detect(position, "DM"),
         wide_midfielder = str_detect(position, "(^M\\s|\\sM\\s)([\\w*\\s*])*(\\(\\w*[RL]\\w*\\)?)"),
         central_midfielder = str_detect(position, "(^M\\s|\\sM\\s)([\\w*\\s*])*(\\(\\w*[C]\\w*\\)?)"),
         winger = str_detect(position, "(^AM\\s|\\sAM\\s)([\\w*\\s*])*(\\(\\w*[RL]\\w*\\)?)"),
         attacking_midfielder = str_detect(position, "(^AM\\s|\\sAM\\s)([\\w*\\s*])*(\\(\\w*[C]\\w*\\)?)"),
         striker = str_detect(position, "ST")) %>%
  mutate(foot_right = mapvalues(foot_right, from = c("Very Weak", "Weak", "Reasonable", "Fairly Strong", "Strong", "Very Strong"),
                                to = c(1, 2, 3, 4, 5, 6)),
         foot_left = mapvalues(foot_left, from = c("Very Weak", "Weak", "Reasonable", "Fairly Strong", "Strong", "Very Strong"),
                                to = c(1, 2, 3, 4, 5, 6))) %>%
  select("name", "age", "height", "goal_keeper", "central_defender", "full_back",
         "defensive_midfielder", "wing_back", "central_midfielder", "wide_midfielder",
         "attacking_midfielder", "winger", "striker", "foot_right", "foot_left",
         "att_cor", "att_cro", "att_dri", "att_fin", "att_fir", "att_fre", "att_hea", "att_lon",
         "att_lth", "att_mar", "att_pas", "att_pen", "att_tck", "att_tec", "att_agg", "att_ant",
         "att_bra", "att_cmp", "att_cnt", "att_dec", "att_det", "att_fla", "att_ldr", "att_otb",
         "att_pos", "att_tea", "att_vis", "att_wor", "att_acc", "att_agi", "att_bal", "att_jum",
         "att_nat", "att_pac", "att_sta", "att_str", "att_aer", "att_cmd", "att_com", "att_ecc",
         "att_han", "att_kic", "att_1v1", "att_pun", "att_ref", "att_tro", "att_thr") %>%
  type.convert(as.is = TRUE)

roles <- matrix(nrow = nrow(squad), ncol = nrow(role_attributes) + 1) %>%
  as.data.frame()
roles[, 1] <- squad$name
colnames(roles) <- c("name", c(paste(role_attributes$position, role_attributes$role, role_attributes$mentality, role_attributes$side, sep = "-")))

for (i in 1:nrow(squad)) {
  
  m <- as.numeric(squad[i, 16:62])
  
  for (j in 1:nrow(role_attributes)) {
    
    n <- as.numeric(role_attributes[j, 5:51])
    
    x <- data.frame(m, n)
    x$prod <- x$m * x$n
    
    roles[i, (j + 1)] <- sum(x$prod) / sum(x$n)
    
    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "goal_keeper" &
        squad[i, 4] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "central_defender" &
        squad[i, 5] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "full_back" &
        squad[i, 6] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "defensive_midfielder" &
        squad[i, 7] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "wing_back" &
        squad[i, 8] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "central_midfielder" &
        squad[i, 9] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "wide_midfielder" &
        squad[i, 10] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "attacking_midfielder" &
        squad[i, 11] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "winger" &
        squad[i, 12] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }

    if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "striker" &
        squad[i, 13] == FALSE) {

      roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2

    }
    
    if ((str_extract(colnames(roles[(j + 1)]), "[^-]+$") == "right" |
         str_extract(colnames(roles[(j + 1)]), "[^-]+$") == "left_inverted") &
         squad[i, 14] %in% c(0, 1, 2, 3, 4)) {
      
      roles[i, (j + 1)] <- 0
      
    }
    
    if ((str_extract(colnames(roles[(j + 1)]), "[^-]+$") == "left" |
         str_extract(colnames(roles[(j + 1)]), "[^-]+$") == "right_inverted") &
         squad[i, 15] %in% c(0, 1, 2, 3, 4)) {
      
      roles[i, (j + 1)] <- 0
      
    }
    
  }
  
}

rm(i, j,
   m, n,
   x)

tactic <- c("goal_keeper-sweeper_keeper-defend-centre-1",
            "central_defender-ball_playing_defender-defend-centre-1",
            "central_defender-ball_playing_defender-defend-centre-2",
            "full_back-full_back-attack-right-1",
            "full_back-full_back-attack-left-1",
            "defensive_midfielder-defensive_midfielder-support-centre-1",
            "defensive_midfielder-defensive_midfielder-support-centre-2",
            "winger-inside_forward-attack-right_inverted-1",
            "winger-inside_forward-support-left_inverted-1",
            "striker-advanced_forward-attack-centre-1",
            "striker-pressing_forward-support-centre-2")

# roles <- roles %>%
#   select("name", all_of(str_extract(tactic, "^.*[-].*(?=-)")))

team <- matrix(nrow = 15, ncol = 11) %>% as.data.frame()
colnames(team) <- tactic

for (i in 1:ncol(team)) {
  
  team[i] <- roles %>%
    arrange(desc(.[[grep(str_extract(colnames(team)[i], "^.*[-].*(?=-)"), colnames(roles))]])) %>% 
    head(n = 15) %>%
    select(name)
  
}

# shuffle <- function(x) sample(x, length(x))
# 
# # Shuffle player lists
# team_shuffled <- lapply(team, shuffle)
# 
# # Generate unique combinations step-by-step and stop after 10 unique combinations
# result <- list()
# count <- 0
# max_combinations <- 1000
# 
# repeat {
#   # Shuffle player lists
#   team_shuffled <- lapply(team, shuffle)
#   
#   combination_found <- FALSE
#   
#   for (gk in team_shuffled$`goal_keeper-sweeper_keeper-defend-centre-1`) {
#     for (cd1 in team_shuffled$`central_defender-ball_playing_defender-defend-centre-1`) {
#       for (cd2 in team_shuffled$`central_defender-ball_playing_defender-defend-centre-2`) {
#         if (cd1 != cd2) {
#           for (fb_r in team_shuffled$`full_back-full_back-attack-right-1`) {
#             if (fb_r != cd1 && fb_r != cd2) {
#               for (fb_l in team_shuffled$`full_back-full_back-attack-left-1`) {
#                 if (fb_l != cd1 && fb_l != cd2 && fb_l != fb_r) {
#                   for (dm1 in team_shuffled$`defensive_midfielder-defensive_midfielder-support-centre-1`) {
#                     if (dm1 != cd1 && dm1 != cd2 && dm1 != fb_r && dm1 != fb_l) {
#                       for (dm2 in team_shuffled$`defensive_midfielder-defensive_midfielder-support-centre-2`) {
#                         if (dm2 != cd1 && dm2 != cd2 && dm2 != fb_r && dm2 != fb_l && dm2 != dm1) {
#                           for (wing_r in team_shuffled$`winger-inside_forward-attack-right_inverted-1`) {
#                             if (wing_r != cd1 && wing_r != cd2 && wing_r != fb_r && wing_r != fb_l && wing_r != dm1 && wing_r != dm2) {
#                               for (wing_l in team_shuffled$`winger-inside_forward-support-left_inverted-1`) {
#                                 if (wing_l != cd1 && wing_l != cd2 && wing_l != fb_r && wing_l != fb_l && wing_l != dm1 && wing_l != dm2 && wing_l != wing_r) {
#                                   for (striker1 in team_shuffled$`striker-advanced_forward-attack-centre-1`) {
#                                     if (striker1 != cd1 && striker1 != cd2 && striker1 != fb_r && striker1 != fb_l && striker1 != dm1 && striker1 != dm2 && striker1 != wing_r && striker1 != wing_l) {
#                                       for (striker2 in team_shuffled$`striker-pressing_forward-support-centre-2`) {
#                                         if (striker2 != cd1 && striker2 != cd2 && striker2 != fb_r && striker2 != fb_l && striker2 != dm1 && striker2 != dm2 && striker2 != wing_r && striker2 != wing_l && striker2 != striker1) {
#                                           result <- append(result, list(data.table(
#                                             Var1 = gk,
#                                             Var2 = cd1,
#                                             Var3 = cd2,
#                                             Var4 = fb_r,
#                                             Var5 = fb_l,
#                                             Var6 = dm1,
#                                             Var7 = dm2,
#                                             Var8 = wing_r,
#                                             Var9 = wing_l,
#                                             Var10 = striker1,
#                                             Var11 = striker2
#                                           )))
#                                           count <- count + 1
#                                           combination_found <- TRUE
#                                           if (count >= max_combinations) {
#                                             outer_loop_break <- TRUE
#                                           }
#                                           break
#                                         }
#                                       }
#                                       if (combination_found) break
#                                     }
#                                   }
#                                   if (combination_found) break
#                                 }
#                               }
#                               if (combination_found) break
#                             }
#                           }
#                           if (combination_found) break
#                         }
#                       }
#                       if (combination_found) break
#                     }
#                   }
#                   if (combination_found) break
#                 }
#               }
#               if (combination_found) break
#             }
#           }
#           if (combination_found) break
#         }
#       }
#       if (combination_found) break
#     }
#     if (combination_found) break
#   }
#   if (count >= max_combinations) {
#     break
#   }
# }
# 
# # Combine the result list into a data.table
# temp <- rbindlist(result)

# temp <- expand.grid(head(team$`goal_keeper-sweeper_keeper-defend-centre-1`, 1),
#                     head(team$`central_defender-ball_playing_defender-defend-centre-1`, 8),
#                     head(team$`central_defender-ball_playing_defender-defend-centre-2`, 8),
#                     head(team$`full_back-full_back-attack-right-1`, 4),
#                     head(team$`full_back-full_back-attack-left-1`, 4),
#                     head(team$`defensive_midfielder-defensive_midfielder-support-centre-1`, 8),
#                     head(team$`defensive_midfielder-defensive_midfielder-support-centre-2`, 8),
#                     head(team$`winger-inside_forward-attack-right_inverted-1`, 4),
#                     head(team$`winger-inside_forward-support-left_inverted-1`, 4),
#                     head(team$`striker-advanced_forward-attack-centre-1`, 4),
#                     head(team$`striker-pressing_forward-support-centre-2`, 4)) %>%
#   mutate(duplicate = ifelse(apply(., 1, function(row) any(duplicated(row))), TRUE, FALSE)) %>%
#   filter(duplicate == FALSE)

temp <- expand.grid(head(team$`goal_keeper-sweeper_keeper-defend-centre-1`, 1),
                    head(team$`central_defender-ball_playing_defender-defend-centre-1`, 4),
                    head(team$`central_defender-ball_playing_defender-defend-centre-2`, 4),
                    head(team$`full_back-full_back-attack-right-1`, 4),
                    head(team$`full_back-full_back-attack-left-1`, 4),
                    head(team$`defensive_midfielder-defensive_midfielder-support-centre-1`, 4),
                    head(team$`defensive_midfielder-defensive_midfielder-support-centre-2`, 4),
                    head(team$`winger-inside_forward-attack-right_inverted-1`, 4),
                    head(team$`winger-inside_forward-support-left_inverted-1`, 4),
                    head(team$`striker-advanced_forward-attack-centre-1`, 4),
                    head(team$`striker-pressing_forward-support-centre-2`, 4))

temp$duplicate <- ifelse(apply(temp, 1, function(row) any(duplicated(row))), "Y", "N")
temp <- temp %>%
  filter(duplicate == "N")

# temp <- crossing(`goal_keeper-sweeper_keeper-defend-centre-1` = head(team$`goal_keeper-sweeper_keeper-defend-centre-1`, 1),
#                  `central_defender-ball_playing_defender-defend-centre-1` = head(team$`central_defender-ball_playing_defender-defend-centre-1`, 4),
#                  `central_defender-ball_playing_defender-defend-centre-2` = head(team$`central_defender-ball_playing_defender-defend-centre-2`, 4),
#                  `full_back-full_back-attack-right-1` = head(team$`full_back-full_back-attack-right-1`, 4),
#                  `full_back-full_back-attack-left-1` = head(team$`full_back-full_back-attack-left-1`, 4),
#                  `defensive_midfielder-defensive_midfielder-support-centre-1` = head(team$`defensive_midfielder-defensive_midfielder-support-centre-1`, 4),
#                  `defensive_midfielder-defensive_midfielder-support-centre-2` = head(team$`defensive_midfielder-defensive_midfielder-support-centre-2`, 4),
#                  `winger-inside_forward-attack-right_inverted-1` = head(team$`winger-inside_forward-attack-right_inverted-1`, 4),
#                  `winger-inside_forward-support-left_inverted-1` = head(team$`winger-inside_forward-support-left_inverted-1`, 4),
#                  `striker-advanced_forward-attack-centre-1` = head(team$`striker-advanced_forward-attack-centre-1`, 4),
#                  `striker-pressing_forward-support-centre-2` = head(team$`striker-pressing_forward-support-centre-2`, 4)) %>%
#   rowwise() %>%
#   mutate(duplicate = any(duplicated(c_across(everything())))) %>%
#   filter(!duplicate) %>%
#   select(-duplicate) %>%
#   ungroup()

temp <- merge(temp, data.frame(name = roles$name, roles$`goal_keeper-sweeper_keeper-defend-centre`), by.x = "Var1", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`central_defender-ball_playing_defender-defend-centre`), by.x = "Var2", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`central_defender-ball_playing_defender-defend-centre`), by.x = "Var3", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`full_back-full_back-attack-right`), by.x = "Var4", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`full_back-full_back-attack-left`), by.x = "Var5", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`defensive_midfielder-defensive_midfielder-support-centre`), by.x = "Var6", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`defensive_midfielder-defensive_midfielder-support-centre`), by.x = "Var7", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`winger-inside_forward-attack-right_inverted`), by.x = "Var8", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`winger-inside_forward-support-left_inverted`), by.x = "Var9", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`striker-advanced_forward-attack-centre`), by.x = "Var10", by.y = "name")
temp <- merge(temp, data.frame(name = roles$name, roles$`striker-pressing_forward-support-centre`), by.x = "Var11", by.y = "name")

temp <- temp %>%
  mutate(strength = rowSums(across(where(is.numeric))))

temp <- temp %>%
  select("gk" = "Var1",
         "gk_strength" = "roles..goal_keeper.sweeper_keeper.defend.centre.",
         "cb-1" = "Var2",
         "cb_strength-1" = "roles..central_defender.ball_playing_defender.defend.centre..x",
         "cb-2" = "Var3",
         "cb_strength-2" = "roles..central_defender.ball_playing_defender.defend.centre..y",
         "fb_r" = "Var4",
         "fb_r_strength" = "roles..full_back.full_back.attack.right.",
         "fb_l" = "Var5",
         "fb_l_strength" = "roles..full_back.full_back.attack.left.",
         "dm-1" = "Var6",
         "dm_strength-1" = "roles..defensive_midfielder.defensive_midfielder.support.centre..x",
         "dm-2" = "Var7",
         "dm_strength-2" = "roles..defensive_midfielder.defensive_midfielder.support.centre..y",
         "am_r" = "Var8",
         "am_r_strength" = "roles..winger.inside_forward.attack.right_inverted.",
         "am_l" = "Var9",
         "am_l_strength" = "roles..winger.inside_forward.support.left_inverted.",
         "st-1" = "Var10",
         "st_strength-1" = "roles..striker.advanced_forward.attack.centre.",
         "st-2" = "Var11",
         "st_strength-2" = "roles..striker.pressing_forward.support.centre.",
         "strength") %>%
  arrange(desc(strength)) %>% type.convert()

best <- c(temp[1, 1], temp[1, 3], temp[1, 5],
          temp[1, 7], temp[1, 9], temp[1, 11],
          temp[1, 13], temp[1, 15], temp[1, 17],
          temp[1, 19], temp[1, 21]) %>% as.vector()

roles2 <- roles %>%
  filter(!(name %in% best))

secondTeam <- matrix(nrow = 15, ncol = 11) %>% as.data.frame()
colnames(secondTeam) <- tactic

for (i in 1:ncol(secondTeam)) {
  
  secondTeam[i] <- roles2 %>%
    arrange(desc(.[[grep(str_extract(colnames(secondTeam)[i], "^.*[-].*(?=-)"), colnames(roles2))]])) %>% 
    head(n = 15) %>%
    select(name)
  
}

temp2 <- expand.grid(head(secondTeam$`goal_keeper-sweeper_keeper-defend-centre-1`, 1),
                     head(secondTeam$`central_defender-ball_playing_defender-defend-centre-1`, 4),
                     head(secondTeam$`central_defender-ball_playing_defender-defend-centre-2`, 4),
                     head(secondTeam$`full_back-full_back-attack-right-1`, 4),
                     head(secondTeam$`full_back-full_back-attack-left-1`, 4),
                     head(secondTeam$`defensive_midfielder-defensive_midfielder-support-centre-1`, 4),
                     head(secondTeam$`defensive_midfielder-defensive_midfielder-support-centre-2`, 4),
                     head(secondTeam$`winger-inside_forward-attack-right_inverted-1`, 4),
                     head(secondTeam$`winger-inside_forward-support-left_inverted-1`, 4),
                     head(secondTeam$`striker-advanced_forward-attack-centre-1`, 4),
                     head(secondTeam$`striker-pressing_forward-support-centre-2`, 4))

temp2$duplicate <- ifelse(apply(temp2, 1, function(row) any(duplicated(row))), "Y", "N")
temp2 <- temp2 %>%
  filter(duplicate == "N")

temp2 <- merge(temp2, data.frame(name = roles$name, roles$`goal_keeper-sweeper_keeper-defend-centre`), by.x = "Var1", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`central_defender-ball_playing_defender-defend-centre`), by.x = "Var2", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`central_defender-ball_playing_defender-defend-centre`), by.x = "Var3", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`full_back-full_back-attack-right`), by.x = "Var4", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`full_back-full_back-attack-left`), by.x = "Var5", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`defensive_midfielder-defensive_midfielder-support-centre`), by.x = "Var6", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`defensive_midfielder-defensive_midfielder-support-centre`), by.x = "Var7", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`winger-inside_forward-attack-right_inverted`), by.x = "Var8", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`winger-inside_forward-support-left_inverted`), by.x = "Var9", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`striker-advanced_forward-attack-centre`), by.x = "Var10", by.y = "name")
temp2 <- merge(temp2, data.frame(name = roles$name, roles$`striker-pressing_forward-support-centre`), by.x = "Var11", by.y = "name")

temp2$strength <- rowSums(temp2[13:23])

temp2 <- temp2 %>%
  select("gk" = "Var1",
         "gk_strength" = "roles..goal_keeper.sweeper_keeper.defend.centre.",
         "cb-1" = "Var2",
         "cb_strength-1" = "roles..central_defender.ball_playing_defender.defend.centre..x",
         "cb-2" = "Var3",
         "cb_strength-2" = "roles..central_defender.ball_playing_defender.defend.centre..y",
         "fb_r" = "Var4",
         "fb_r_strength" = "roles..full_back.full_back.attack.right.",
         "fb_l" = "Var5",
         "fb_l_strength" = "roles..full_back.full_back.attack.left.",
         "dm-1" = "Var6",
         "dm_strength-1" = "roles..defensive_midfielder.defensive_midfielder.support.centre..x",
         "dm-2" = "Var7",
         "dm_strength-2" = "roles..defensive_midfielder.defensive_midfielder.support.centre..y",
         "am_r" = "Var8",
         "am_r_strength" = "roles..winger.inside_forward.attack.right_inverted.",
         "am_l" = "Var9",
         "am_l_strength" = "roles..winger.inside_forward.support.left_inverted.",
         "st-1" = "Var10",
         "st_strength-1" = "roles..striker.advanced_forward.attack.centre.",
         "st-2" = "Var11",
         "st_strength-2" = "roles..striker.pressing_forward.support.centre.",
         "strength") %>%
  arrange(desc(strength))





### Free Roles ###

roles <- matrix(nrow = nrow(squad), ncol = nrow(role_attributes) + 2) %>%
  as.data.frame()
roles[, 1] <- squad$name
roles[, 2] <- squad$age

df <- c(paste(role_attributes$position, role_attributes$role, role_attributes$mentality, role_attributes$side, sep = "-"))
df <- c("name", "age", df)
colnames(roles) <- df

for (i in 1:nrow(squad)) {
  
  m <- as.numeric(squad[i, 16:62])
  
  for (j in 1:(nrow(role_attributes))) {
    
    n <- as.numeric(role_attributes[j, 5:51])
    
    x <- data.frame(m, n)
    x$prod <- x$m * x$n
    
    roles[i, (j + 2)] <- sum(x$prod) / sum(x$n)
    
    if (roles$age[i] > 21) {
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "goal_keeper" &
          squad[i, 4] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "central_defender" &
          squad[i, 5] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "full_back" &
          squad[i, 6] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "defensive_midfielder" &
          squad[i, 7] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "wing_back" &
          squad[i, 8] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "central_midfielder" &
          squad[i, 9] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "wide_midfielder" &
          squad[i, 10] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "attacking_midfielder" &
          squad[i, 11] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "winger" &
          squad[i, 12] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
      if (str_extract(colnames(roles[(j + 1)]), "^[^-]*") == "striker" &
          squad[i, 13] == FALSE) {
        
        roles[i, (j + 1)] <- roles[i, (j + 1)] * 0.2
        
      }
      
    }
    
    if ((str_extract(colnames(roles[(j + 1)]), "[^-]+$") == "right" |
         str_extract(colnames(roles[(j + 1)]), "[^-]+$") == "left_inverted") &
        squad[i, 14] %in% c(0, 1, 2, 3, 4)) {
      
      roles[i, (j + 1)] <- 0
      
    }
    
    if ((str_extract(colnames(roles[(j + 1)]), "[^-]+$") == "left" |
         str_extract(colnames(roles[(j + 1)]), "[^-]+$") == "right_inverted") &
        squad[i, 15] %in% c(0, 1, 2, 3, 4)) {
      
      roles[i, (j + 1)] <- 0
      
    }
    
  }
  
}

best_positions <- roles
best_positions$position <- best_positions %>% select(-c(1:2)) %>% {names(.)[max.col(.)]}
best_positions <- best_positions %>%
  select("name", "position")

roles_free <- roles %>%
  filter(!(name %in% c(unlist(bind_rows(temp[1, ], temp2[1, ]))))) %>%
  left_join(best_positions) %>%
  select("name", "age", "position")

clipr::write_clip(bind_rows(temp[1, ], temp2[1, ]) %>%
                    mutate(across(where(is.numeric), ~ round(.x, 2))))
