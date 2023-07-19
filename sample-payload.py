import requests
import json

url = "http://localhost:7071/query"
data = {
   "queries" : [
       {
            "query": "Where is ToDO list?"  ,
            #"filter" : {"author" : "Bob"}  ,
            "top_k"  : 1
            
        }
   ]
   
}



response = requests.post(url, data=json.dumps(data))
#print(response.content)



json_response = response.json()

data = json_response['results'][0]['results']

for item in data:
    print(item['metadata']['source_id'])


