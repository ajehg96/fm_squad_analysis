import numpy as np
import pandas as pd
from scipy.optimize import linear_sum_assignment
from bs4 import BeautifulSoup
import re

# Set up paths and constants
TACTIC_ROLES = pd.DataFrame({
    'position': ["gk_sk_d_c", "cd_bpd_d_c", "wb_wb_a_r", "dm_sv_a_c",
                 "wb_wb_a_l", "w_if_a_ri", "w_if_a_li", "s_af_a_c"],
    'number': [1, 3, 1, 2, 1, 1, 1, 1]
})

# Helper functions
def create_role_code(row):
    return (f"{''.join([x[0] for x in row['position'].split('_')])}_"
            f"{''.join([x[0] for x in row['role'].split('_')])}_"
            f"{''.join([x[0] for x in row['mentality'].split('_')])}_"
            f"{''.join([x[0] for x in row['side'].split('_')])}")

# Import data
role_attributes = pd.read_csv('c:/Users/AJEHG/OneDrive/Documents/R/footballManager/data/role_attributes.csv', na_values=['', '#NA'])
role_attributes = role_attributes.convert_dtypes()
role_attributes['role_code'] = role_attributes.apply(create_role_code, axis=1)
role_attributes = role_attributes[role_attributes['role_code'].isin(TACTIC_ROLES['position'])]

# Squad data processing
with open('data/squad.html', 'r', encoding='utf-8') as f:
    soup = BeautifulSoup(f, 'html.parser')

table = soup.find('table')
squad = pd.read_html(str(table))[0]
squad = squad.dropna(subset=squad.columns[7:50], how='all')
# ... continue column processing similar to R code ...

# Position flags and foot conversion
foot_mapping = {'Very Weak': 1, 'Weak': 2, 'Reasonable': 3, 
                'Fairly Strong': 4, 'Strong': 5, 'Very Strong': 6}
squad['foot_right'] = squad['foot_right'].map(foot_mapping)
squad['foot_left'] = squad['foot_left'].map(foot_mapping)

# Role ratings calculation
def calculate_ratings(df, role_df, tactic_roles, fixed=True):
    ratings = pd.DataFrame({'name': df['name'], 'age': df['age']})
    
    for _, role in role_df.iterrows():
        role_code = role['role_code']
        weights = role.iloc[1:-1].astype(float)
        
        scores = df[weights.index].values @ weights.values
        scores /= weights.sum()
        
        # Apply position suitability penalties
        pos_prefix = role_code.split('_')[0]
        pos_map = {
            'gk': 'goal_keeper',
            'cd': 'central_defender',
            'wb': 'wing_back',
            # ... add other position mappings ...
        }
        
        if fixed and pos_prefix in pos_map:
            mask = df[pos_map[pos_prefix]] == False
            scores[mask] *= 0.2
        
        # Apply foot penalties
        if role_code.endswith(('r', 'li')):
            mask = df['foot_right'].isin([0,1,2,3,4])
            scores[mask] = 0
        if role_code.endswith(('l', 'ri')):
            mask = df['foot_left'].isin([0,1,2,3,4])
            scores[mask] = 0
        
        ratings[role_code] = scores
    
    return ratings

roles_position = calculate_ratings(squad, role_attributes, TACTIC_ROLES)
roles_free = calculate_ratings(squad, role_attributes, TACTIC_ROLES, fixed=False)

# Hungarian algorithm implementation
def assign_team(data, tactic_roles, current_assignments=None):
    df = data.copy()
    if current_assignments:
        df = df[~df['name'].isin(current_assignments)]
    
    # Expand columns based on tactic roles
    expanded_cols = []
    for _, row in tactic_roles.iterrows():
        expanded_cols.extend([row['position']] * row['number'])
    
    cost_matrix = df[expanded_cols].values
    cost_matrix = -cost_matrix  # Convert to minimization problem
    row_ind, col_ind = linear_sum_assignment(cost_matrix)
    
    assignments = pd.DataFrame({
        'position': [expanded_cols[i] for i in col_ind],
        'name': df.iloc[row_ind]['name'].values,
        'score': cost_matrix[row_ind, col_ind] * -1
    })
    
    return assignments

# Team assignments
first_team = assign_team(roles_position, TACTIC_ROLES)
second_team = assign_team(roles_position, TACTIC_ROLES, first_team['name'])
third_team = assign_team(roles_position, TACTIC_ROLES, 
                        pd.concat([first_team['name'], second_team['name']]))

# Output results
print(pd.concat([
    first_team.reset_index(drop=True),
    second_team.reset_index(drop=True),
    third_team.reset_index(drop=True)
], axis=1))