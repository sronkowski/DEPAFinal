import pandas as pd
import pymysql
import db_interaction
import argparse
import yaml
import sys

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', help='configuration file including data read and write paths')
    parser.add_argument('--db_config', help='configuration file including db connection info')
	parser.add_argument('--num_rows', help='number of rows of each df to add to db (use for testing)', default=-1)
    
    return parser.parse_args()

def read_config(path):
    with open(path) as f:
        # use safe_load instead load
        config = yaml.safe_load(f)
    return config

if __name__ == "__main__":
    args = get_args()
    
    try:
        config = read_config(args.config)
    except:
        sys.exit('ERROR: unable to read config file')
    
    try:
        db_config = read_config(args.db_config)
    except:
        sys.exit('ERROR: unable to read db_config file')
    
	num_rows = args.num_rows
	
    host = db_config['db_host']
    user = db_config['db_user']
    pwd = db_config['db_password']
    schema = db_config['db_schema']

    engine = db_interaction.db_create_engine(user, pwd, host, schema)
    con = pymysql.connect(host, user, pwd)

    zip_code_id_map = pd.read_sql('SELECT * FROM real_estate_value.zip_code', con)
    zip_code_id_map.drop(columns=['city_id'], inplace=True)
    zip_code_id_map['zip_code'] = zip_code_id_map['zip_code'].astype(int)

    drop_list = ["City","State","Metro","CountyName","SizeRank","StateName","RegionID"]

    for k,v in config['file_name_to_table_map'].items():
        df = pd.read_csv(config['read_path'] + k, encoding='latin')
        drop_set = set(drop_list) & set(df.columns)
        df.drop(columns=drop_set, inplace=True)
        df = df.melt(id_vars=['RegionName']).rename(columns={'value':v['value_name']})
        df = df.join(df['variable'].str.split('-', expand=True).rename(columns={0:'year', 1:'month'}))
        df.drop(columns=['variable'], inplace=True)
        df = df.merge(zip_code_id_map, how='left', left_on='RegionName', right_on='zip_code')
        df.dropna(subset=['zip_code_id'], inplace=True)
        df.drop(columns=['RegionName', 'zip_code'], inplace=True)
        df.to_csv(config['write_path'] + v['table'] + '.csv', index=False)
		if num_rows <= 0:
			db_interaction.append_df_to_existing_table(df, v['table'], schema, engine)
		else:
			db_interaction.append_df_to_existing_table(df.head(num_rows), v['table'], schema, engine)
    
    