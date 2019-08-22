import pandas as pd
import requests
import re
import time
import argparse
import sys
import yaml

def read_config(path):
    with open(path) as f:
        # use safe_load instead load
        config = yaml.safe_load(f)
    return config

def get_data_set_year(year, base, data_set, geography, api_key):
    print(base.format(year, ','.join(data_set.values()), geography, api_key))
    resp = requests.get(base.format(year, ','.join(data_set.values()), geography, api_key))

    if resp.status_code == 200:
        lines = re.sub(r'[\[\]"]' , '', resp.text).split(',\n')

        data = [line.split(',') for line in lines]

        df = pd.DataFrame(data[1:], columns=data[0]).rename(columns={v:k for k, v in data_set.items()})
        df = df.melt(id_vars='zip code tabulation area', value_vars=list(data_set.keys()))
        df['year'] = year
        return df
    else:
        print("API ERROR")
        return pd.DataFrame()

def get_data_set_year_range(start, end, base, data_set, geography, api_key):
    df_list = []
    for year in range(start, end+1):
        # only make one API call per second
        time.sleep(1)
        
        temp = get_data_set_year(year, base, data_set, geography, api_key)
        if not temp.empty:
            temp['year'] = year
            df_list.append(temp)
    
    if len(df_list) > 0:
        df = pd.concat(df_list)
    else:
        df = pd.DataFrame()
    return df

def get_all_data_sets(config, start=2011, end=2017):
    base = config['base_url']
    geography = config['geography']
    api_key = config['api_key']
    
    for ds_name, ds_val in config['data_sets'].items():
        s = start
        if 'min_year_valid' in ds_val.keys():
            s = max(start, ds_val['min_year_valid'])
        
        df = get_data_set_year_range(s, end, base, ds_val['fields'], geography, api_key)
        if not df.empty:
            df.to_csv(config['write_path'] + ds_name +'.csv', index=False)
        else:
            print("ERROR: produced no dataframe for {}".format(ds_name))

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--start', help='start year', default=2011)
    parser.add_argument('--end', help='end year', default=2017)
    parser.add_argument('--config', help='config file path and name')
    
    return parser.parse_args()

if __name__ == "__main__":
    args = get_args()
	
    try:
        config = read_config(args.config)
    except:
        sys.exit('unable to read config file')
    start = args.start
    end = args.end
    
    get_all_data_sets(config, start, end)