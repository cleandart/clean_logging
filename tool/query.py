from pymongo import MongoClient
client = MongoClient('mongodb://0.0.0.0:27017/logger')
logs = client['logger']['logs']

def find(options, limit=50):
  for log in sorted(logs.find(options).sort("timestamp",-1).limit(limit), key=lambda k: k['timestamp']):
    print log

def last():
  find({})

