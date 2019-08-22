import requests
import yaml
import argparse

def read_config(path):
    with open(path) as f:
        # use safe_load instead load
        config = yaml.safe_load(f)
    return config

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', help='config file path and name')
    
    return parser.parse_args()


if __name__ == "__main__":
    args = get_args()
    
    try:
        config = read_config(args.config)
    except:
        sys.exit('unable to read config file')
    
    urls = config['urls']
    path = config['write_path']
    
    for url in urls:
        r = requests.get(url, allow_redirects=True)
        filename = urls[0].split('/')[-1]
        with open(path + filename, 'wb') as f:
            f.write(r.content)