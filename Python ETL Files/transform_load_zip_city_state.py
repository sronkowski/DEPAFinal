#!/usr/bin/env python
# coding: utf-8


import pandas as pd
import db_interaction
import argparse
import yaml
import sys


def read_config(path):
    with open(path) as f:
        # use safe_load instead load
        config = yaml.safe_load(f)
    return config
	
def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', help='configuration file including data read and write paths')
    parser.add_argument('--db_config', help='configuration file including db connection info')
    
    return parser.parse_args()

if __name__ == "__main__":
    args = get_args()
	
    try:
        config = read_config(args.config)
    except:
        sys.exit('unable to read config file')
	
    try:
        db_config = read_config(args.db_config)
    except:
        sys.exit('unable to read config file')
    
    host = db_config['db_host']
    user = db_config['db_user']
    pwd = db_config['db_password']
    schema = db_config['db_schema']
    
    # read file
    df = pd.read_csv(config['read_path'])
    df.drop(columns=['stcountyfp', 'classfp'], inplace=True)
    df.rename(columns={'countyname':'county'}, inplace=True)
    
    engine = db_interaction.db_create_engine(user, pwd, host, schema)
    
    # get states
    states = pd.DataFrame(df['state'].unique(), columns=['state'])
    states.reset_index(inplace=True)
    states.rename(columns={'index': 'state_id', 'state':'state_code'}, inplace=True)
    states['state_id'] += 1
    states.to_csv(config['write_path'] + '/state.csv', index=False)
    db_interaction.append_df_to_existing_table(states, 'state', schema, engine)
    
    # get counties
    df = df.merge(states, how='left', left_on='state', right_on='state_code')
    county = df.groupby(['state_id', 'county'])['zip', 'city'].min()
    county.reset_index(inplace=True)
    county.drop(columns=['zip', 'city'], inplace=True)
    county.reset_index(inplace=True)
    county.rename(columns={'index': 'county_id', 'county':'county_name'}, inplace=True)
    county['county_id'] += 1
    county.to_csv(config['write_path'] + '/county.csv', index=False)
    db_interaction.append_df_to_existing_table(county, 'county', schema, engine)
    
    # get cities
    df = df.merge(county, how='left', left_on=['state_id', 'county'], right_on=['state_id', 'county_name'])
    city = df.groupby(['county_id', 'city'])['zip', 'state_id'].min()
    city.reset_index(inplace=True)
    city.drop(columns=['zip', 'state_id'], inplace=True)
    city.reset_index(inplace=True)
    city.rename(columns={'index': 'city_id', 'city':'city_name'}, inplace=True)
    city['city_id'] += 1
    city.to_csv(config['write_path'] + '/city.csv', index=False)
    db_interaction.append_df_to_existing_table(city, 'city', schema, engine)
    
    # get zip codes
    df = df.merge(city, how='left', left_on=['county_id', 'city'], right_on=['county_id', 'city_name'])
    postal_code = df.groupby(['city_id', 'zip'])['county_id', 'state_id'].min()
    postal_code.reset_index(inplace=True)
    postal_code.drop(columns=['county_id', 'state_id'], inplace=True)
    postal_code.drop_duplicates(subset='zip', inplace=True)
    postal_code.reset_index(inplace=True)
    postal_code.rename(columns={'index': 'zip_code_id', 'zip':'zip_code'}, inplace=True)
    postal_code['zip_code_id'] += 1
    postal_code.to_csv(config['write_path'] + '/zip_code.csv', index=False)
    db_interaction.append_df_to_existing_table(postal_code, 'zip_code', schema, engine)
