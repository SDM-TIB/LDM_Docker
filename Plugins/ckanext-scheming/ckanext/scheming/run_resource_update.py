from crontab import CronTab
import argparse
import urllib.request
from datetime import datetime

print("Start script")

cron = CronTab(user='root')
job = cron.find_comment('tib_update_resource')

#print(job)
home_path = ""
for item1 in job:
    home_path = item1.env['home_path']

parser = argparse.ArgumentParser(description='Script so useful.')
parser.add_argument("-t")

args = parser.parse_args()

type = args.t

valid_types = ['daily','weekly','monthly']
if type in valid_types:
    url = home_path + '/tib_resource_update/' + type
    contents = urllib.request.urlopen(url).read()

print(datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
print("type: "+type)
print("url:"+ url)
print("**********************************", flush=True)