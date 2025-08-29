##### Packages & Functions #####

library(clue)
library(data.table)
library(rlist)
library(plyr)
library(tidyverse)
library(XML)

setwd("C:/Users/AJEHG/OneDrive/Documents/R/footballManager")

##### Import Data #####

### Tactical Roles ###

tactic_roles <- data.frame(position = c("gk_sk_d_c",
                                        "cd_bpd_d_c",
                                        "wb_wb_a_r",
                                        "dm_sv_a_c",
                                        "wb_wb_a_l",
                                        "w_if_a_ri",
                                        "w_if_a_li",
                                        "s_af_a_c"),
                           number = c(1, 3, 1, 2, 1, 1, 1, 1))

### Role Attributes ###

role_attributes <- fread("data/role_attributes.csv", na.strings=c("", "#NA")) %>%
  type.convert(as.is = TRUE) %>%
  rowwise() %>%
  mutate(role_code = paste0(sapply(str_split(position, "_"), function(x) paste(substr(x, 1, 1), collapse = "")), "_",
                            sapply(str_split(role, "_"), function(x) paste(substr(x, 1, 1), collapse = "")), "_",
                            sapply(str_split(mentality, "_"), function(x) paste(substr(x, 1, 1), collapse = "")), "_",
                            sapply(str_split(side, "_"), function(x) paste(substr(x, 1, 1), collapse = "")))) %>%
  select(5:ncol(.)) %>%
  filter(role_code %in% tactic_roles$position)

# role_attributes[role_attributes == 0.1] <- 0

### Squad Attributes ###

squad <- htmlParse("data/squad.html", encoding = "UTF-8")
squad <- readHTMLTable(squad) %>%
  as.data.frame() %>%
  filter(!if_any(8:50, ~ str_detect(.x, "-"))) %>%
  select("name" = "NULL.Name", "age" = "NULL.Age", "height" = "NULL.Height", "position" = "NULL.Position",
         "foot_right" = "NULL.Right.Foot", "foot_left" = "NULL.Left.Foot", "potential" = "NULL.PA", "att_cor" = "NULL.Cor",
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
         "att_han", "att_kic", "att_1v1", "att_pun", "att_ref", "att_tro", "att_thr", "potential") %>%
  type.convert(as.is = TRUE)

##### Generate Role Ratings #####

### Fixed Roles ###

roles_position <- matrix(nrow = nrow(squad), ncol = nrow(role_attributes) + 2) %>%
  as.data.frame()
roles_position[, 1] <- squad$name
roles_position[, 2] <- squad$age

df <- c(role_attributes$role_code)
df <- c("name", "age", df)
colnames(roles_position) <- df

for (i in 1:nrow(squad)) {
  
  m <- as.numeric(squad[i, 16:62])
  
  for (j in 1:nrow(role_attributes)) {
    
    n <- as.numeric(role_attributes[j, 2:ncol(role_attributes)])
    
    x <- data.frame(m, n)
    x$prod <- x$m * x$n
    
    roles_position[i, (j + 2)] <- sum(x$prod) / sum(x$n)
    
    if (str_starts(colnames(roles_position[(j + 2)]), "gk_") &
        squad[i, 4] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "cd_") &
        squad[i, 5] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "fb_") &
        squad[i, 6] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "dm_") &
        squad[i, 7] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "wb_") &
        squad[i, 8] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "cm_") &
        squad[i, 9] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "wm_") &
        squad[i, 10] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "am_") &
        squad[i, 11] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "w_") &
        squad[i, 12] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if (str_starts(colnames(roles_position[(j + 2)]), "s_") &
        squad[i, 13] == FALSE) {
      
      roles_position[i, (j + 2)] <- roles_position[i, (j + 2)] * 0.2
      
    }
    
    if ((str_ends(colnames(roles_position[(j + 2)]), "r") |
         str_ends(colnames(roles_position[(j + 2)]), "li")) &
        squad[i, 14] %in% c(0, 1, 2, 3, 4)) {
      
      roles_position[i, (j + 2)] <- 0
      
    }
    
    if ((str_ends(colnames(roles_position[(j + 2)]), "l") |
         str_ends(colnames(roles_position[(j + 2)]), "ri")) &
        squad[i, 15] %in% c(0, 1, 2, 3, 4)) {
      
      roles_position[i, (j + 2)] <- 0
      
    }
    
  }
  
}

roles_position <- roles_position %>%
  arrange(name)

### Free Roles ###

roles_free <- matrix(nrow = nrow(squad), ncol = nrow(role_attributes) + 2) %>%
  as.data.frame()
roles_free[, 1] <- squad$name
roles_free[, 2] <- squad$age

df <- c(role_attributes$role_code)
df <- c("name", "age", df)
colnames(roles_free) <- df

for (i in 1:nrow(squad)) {
  
  m <- as.numeric(squad[i, 16:62])
  
  for (j in 1:(nrow(role_attributes))) {
    
    n <- as.numeric(role_attributes[j, 2:ncol(role_attributes)])
    
    x <- data.frame(m, n)
    x$prod <- x$m * x$n
    
    roles_free[i, (j + 2)] <- sum(x$prod) / sum(x$n)
    
    if (str_starts(colnames(roles_free[(j + 2)]), "gk_") &
        squad[i, 4] == FALSE) {
      
      roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
      
    }
    
    if (roles_free$age[i] > 21) {
      
      if (str_starts(colnames(roles_free[(j + 2)]), "cd_") &
          squad[i, 5] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
      if (str_starts(colnames(roles_free[(j + 2)]), "fb_") &
          squad[i, 6] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
      if (str_starts(colnames(roles_free[(j + 2)]), "dm_") &
          squad[i, 7] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
      if (str_starts(colnames(roles_free[(j + 2)]), "wb_") &
          squad[i, 8] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
      if (str_starts(colnames(roles_free[(j + 2)]), "cm_") &
          squad[i, 9] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
      if (str_starts(colnames(roles_free[(j + 2)]), "wm_") &
          squad[i, 10] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
      if (str_starts(colnames(roles_free[(j + 2)]), "am_") &
          squad[i, 11] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
      if (str_starts(colnames(roles_free[(j + 2)]), "w_") &
          squad[i, 12] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
      if (str_starts(colnames(roles_free[(j + 2)]), "s_") &
          squad[i, 13] == FALSE) {
        
        roles_free[i, (j + 2)] <- roles_free[i, (j + 2)] * 0.2
        
      }
      
    }
    
    if ((str_ends(colnames(roles_free[(j + 2)]), "r") |
         str_ends(colnames(roles_free[(j + 2)]), "li")) &
         squad[i, 14] %in% c(0, 1, 2, 3, 4)) {
      
      roles_free[i, (j + 2)] <- 0
      
    }
    
    if ((str_ends(colnames(roles_free[(j + 2)]), "l") |
         str_ends(colnames(roles_free[(j + 2)]), "ri")) &
         squad[i, 15] %in% c(0, 1, 2, 3, 4)) {
      
      roles_free[i, (j + 2)] <- 0
      
    }
    
    # if ((str_ends(colnames(roles_first[(j + 2)]), "r") |
    #      str_ends(colnames(roles_first[(j + 2)]), "li")) &
    #     squad[i, 14] %in% c(0, 1, 2, 3, 4)) {
    #   
    #   roles_first[i, (j + 2)] <- 0
    #   
    # }
    # 
    # if ((str_ends(colnames(roles_first[(j + 2)]), "l") |
    #      str_ends(colnames(roles_first[(j + 2)]), "ri")) &
    #     squad[i, 15] %in% c(0, 1, 2, 3, 4)) {
    #   
    #   roles_first[i, (j + 2)] <- 0
    #   
    # }
    
  }
  
}

roles_free <- roles_free %>%
  arrange(name)

##### Run Hungarian Algorithm #####

### First Team ###

# Create Normalised Square Cost Matrix #

data <- roles_position

for (i in 1:nrow(tactic_roles)) {
  position_col <- tactic_roles$position[i]
  num_players <- tactic_roles$number[i]
  
  if (num_players > 1) {
    for (n in 2:num_players) {
      new_col_name <- paste0(position_col, "_", n)
      data <- data %>%
        mutate(!!new_col_name := .[[position_col]])
    }
  }
}

rm(num_players,
   new_col_name,
   position_col)

first_team_matrix <- data %>%
  select(- c(name, age)) %>%
  as.matrix()

constant <- abs(min(first_team_matrix)) + 1
normalised_first_team_matrix <- first_team_matrix + constant

if (nrow(normalised_first_team_matrix) > ncol(normalised_first_team_matrix)) {
  
  padding <- matrix(constant * 2, nrow = nrow(normalised_first_team_matrix), ncol = nrow(normalised_first_team_matrix) - ncol(normalised_first_team_matrix))
  
  normalised_first_team_matrix <- cbind(normalised_first_team_matrix, padding)
  
}

# Apply the Algorithm #

assignment <- solve_LSAP(normalised_first_team_matrix, maximum = TRUE)

first_team_indices <- cbind(which(assignment <= ncol(first_team_matrix)), assignment[assignment <= ncol(first_team_matrix)])
first_team <- tibble(position = colnames(data)[3:ncol(data)][first_team_indices[, 2]],
                     name = data$name[first_team_indices[, 1]],
                     score = first_team_matrix[first_team_indices]) %>%
  mutate(position = ifelse(str_ends(position, "\\d"), str_sub(position, 1, -3), position),
         position = factor(position, levels = role_attributes$role_code)) %>%
  arrange(position, desc(score))

first_team_strength <- sum(first_team$score)

### Second Team ###

# Create Normalised Square Cost Matrix #

data <- roles_position %>%
  filter(!name %in% c(first_team %>% pull(name)))

for (i in 1:nrow(tactic_roles)) {
  position_col <- tactic_roles$position[i]
  num_players <- tactic_roles$number[i]
  
  if (num_players > 1) {
    for (n in 2:num_players) {
      new_col_name <- paste0(position_col, "_", n)
      data <- data %>%
        mutate(!!new_col_name := .[[position_col]])
    }
  }
}

rm(num_players,
   new_col_name,
   position_col)

second_team_matrix <- data %>%
  select(- c(name, age)) %>%
  as.matrix()

constant <- abs(min(second_team_matrix)) + 1
normalised_second_team_matrix <- second_team_matrix + constant

if (nrow(normalised_second_team_matrix) > ncol(normalised_second_team_matrix)) {
  
  padding <- matrix(constant * 2, nrow = nrow(normalised_second_team_matrix), ncol = nrow(normalised_second_team_matrix) - ncol(normalised_second_team_matrix))
  
  normalised_second_team_matrix <- cbind(normalised_second_team_matrix, padding)
  
}

# Apply the Algorithm #

assignment <- solve_LSAP(normalised_second_team_matrix, maximum = TRUE)

second_team_indices <- cbind(which(assignment <= ncol(second_team_matrix)), assignment[assignment <= ncol(second_team_matrix)])
second_team <- tibble(position = colnames(data)[3:ncol(data)][second_team_indices[, 2]],
                      name = data$name[second_team_indices[, 1]],
                      score = second_team_matrix[second_team_indices]) %>%
  mutate(position = ifelse(str_ends(position, "\\d"), str_sub(position, 1, -3), position),
         position = factor(position, levels = role_attributes$role_code)) %>%
  arrange(position, desc(score))

second_team_strength <- sum(second_team$score)

### Third Team ###

# Create Normalised Square Cost Matrix #

data <- roles_position %>%
  filter(!name %in% c(first_team %>% pull(name), second_team %>% pull(name)) &
           age < 22) %>%
  left_join(squad %>% select("name", "age", "potential"),
            by  = c("name", "age")) %>%
  mutate(across(3:(ncol(.) - 1), ~ .x * (potential / 200))) %>%
  select(-c("potential"))
  
for (i in 1:nrow(tactic_roles)) {
  position_col <- tactic_roles$position[i]
  num_players <- tactic_roles$number[i]
  
  if (num_players > 1) {
    for (n in 2:num_players) {
      new_col_name <- paste0(position_col, "_", n)
      data <- data %>%
        mutate(!!new_col_name := .[[position_col]])
    }
  }
}

rm(num_players,
   new_col_name,
   position_col)

third_team_matrix <- data %>%
  select(- c(name, age)) %>%
  as.matrix()

constant <- abs(min(third_team_matrix)) + 1
normalised_third_team_matrix <- third_team_matrix + constant

if (nrow(normalised_third_team_matrix) > ncol(normalised_third_team_matrix)) {
  
  padding <- matrix(constant * 2, nrow = nrow(normalised_third_team_matrix), ncol = nrow(normalised_third_team_matrix) - ncol(normalised_third_team_matrix))
  
  normalised_third_team_matrix <- cbind(normalised_third_team_matrix, padding)
  
}

# Apply the Algorithm #

assignment <- solve_LSAP(normalised_third_team_matrix, maximum = TRUE)

third_team_indices <- cbind(which(assignment <= ncol(third_team_matrix)), assignment[assignment <= ncol(third_team_matrix)])
third_team <- tibble(position = colnames(data)[3:ncol(data)][third_team_indices[, 2]],
                      name = data$name[third_team_indices[, 1]],
                      score = third_team_matrix[third_team_indices]) %>%
  mutate(position = ifelse(str_ends(position, "\\d"), str_sub(position, 1, -3), position),
         position = factor(position, levels = role_attributes$role_code)) %>%
  arrange(position, desc(score))

third_team_strength <- sum(third_team$score)

##### Rest of the Squad #####

best_positions <- roles_position %>%
  select(-matches("\\d+$")) %>%
  filter(!name %in% c(first_team %>% pull(name), second_team %>% pull(name), third_team %>% pull(name))) %>%
  pivot_longer(cols = 3:ncol(.), names_to = "position", values_to = "score") %>%
  group_by(name) %>%
  slice_max(order_by = score, n = 1) %>%
  ungroup()

# ##### Player Development #####
# 
# if (file.exists("data/player_development.csv")) {
# 
#   player_development <- fread("data/player_development.csv")
# 
#   month <- as.numeric(str_sub(colnames(player_development)[ncol(player_development)], 1, 1)) + 1
#   position_name <- paste0(month, "_position")
#   score_name <- paste0(month, "_score")
# 
#   player_development <- player_development %>%
#     full_join(bind_rows(best_positions[c(1, 3:4)], first_team[1:3], second_team[1:3], third_team[1:3])) %>%
#     mutate(!!position_name := position,
#            !!score_name := score) %>%
#     select(-c("position", "score"))
# 
#   fwrite(player_development, "data/player_development.csv")
# 
# } else {
# 
#   player_development <- squad %>%
#     select("name") %>%
#     left_join(bind_rows(best_positions[c(1, 3:4)], first_team[1:3], second_team[1:3])) %>%
#     rename("1_position" = "position", "1_score" = "score")
# 
#   fwrite(player_development, "data/player_development.csv")
# 
# }
# 
# rm(month, position_name, score_name)

##### Clean Up the Workspace #####

rm(assignment, constant, data, df, i, j, m, n, padding, x,
   first_team_indices, first_team_matrix, normalised_first_team_matrix,
   second_team_indices, second_team_matrix, normalised_second_team_matrix,
   third_team_indices, third_team_matrix, normalised_third_team_matrix)

clipr::write_clip(bind_cols(first_team, second_team, third_team) %>%
                    select(-c(4, 7)))