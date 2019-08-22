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
    
    engine = db_interaction.db_create_engine(user, pwd, host, schema)
    
    # read file
    df = pd.read_csv(config['read_path'])
    df.dropna(inplace=True)
    df.rename(columns={'MortgageRateConventionalFixed':'rate', 'Date':'date'}, inplace=True)

    df['date'] = pd.to_datetime(df['date'] + ' ' + df['TimePeriod'])
    df.drop(columns=['TimePeriod'], inplace=True)

    df['year'] = df['date'].dt.year
    df['month'] = df['date'].dt.month

    df = df.groupby(['year', 'month'])['rate'].mean().reset_index()

    df.to_csv(config['write_path'] + '/mortgage_rates_transformed.csv', index=False)
    db_interaction.append_df_to_existing_table(df, 'mortgage_rate', schema, engine)