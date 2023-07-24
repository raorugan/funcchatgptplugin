 The ChatGPT Retrieval Plugin lets you easily search and find personal or work documents by asking questions in everyday language.
 Follow these steps to quickly set up and run the ChatGPT Retrieval Plugin using Azure Functions on Azure Container Apps :

![image](https://github.com/raorugan/funcchatgptplugin/assets/45637559/7e7c9d38-76da-4248-9802-2ce99665a793)


 
## Prerequisites:
 
- Python 3.10
- Azure CLI version 2.47 or later.
- You also need an Azure account with an active subscription. Create an account for free.
-  Docker is installed, have a Docker ID and Docker is started
- Azure Database for PostgreSQL flexible server
- Azure OpenAI service

## Deploy the chatgpt function app plugin
- Clone the repository: git clone (https://github.com/raorugan/funcchatgptplugin.git)
-  Navigate to the cloned repository directory: cd /path/to/funcchatgptplugin
-   Build a container image
 
  ```sh
    docker build  --tag <DOCKER_ID>/<chatgptpluginfuncimagename>:<tag> .
```
- Push the image to a container registry
```sh
docker push <DOCKER_ID>/<chatgptpluginfuncimagename>:<tag>
```
## Create Azure resources

##  Using the plugin with Azure OpenAI
The Azure Open AI uses URLs that are specific to your resource and references models not by model name but by the deployment id. As a result, you need to set additional environment variables for this case.
In addition to the OPENAI_API_BASE (your specific URL) and OPENAI_API_TYPE (azure), you should also set OPENAI_EMBEDDINGMODEL_DEPLOYMENTID which specifies the model to use for getting embeddings on upsert and query. For this, we recommend deploying text-embedding-ada-002 model and using the deployment name here.
[Create a resource and deploy a model using Azure OpenAI](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource?pivots=web-portal)

## Create a Vector database
Create an [Azure database for PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-portal).
Post successful creation enable the pgvector extension either by using portal. Go to the Azure PostGreSQL database resource page -> Server Parameters -> azure.extensions -> Select Vector OR follow these [instructions](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-use-pgvector) to install using AzCLI
Once the database is installed with extension create the table - documents
## Export environment variables required for the Postgres Datastore
```
export PG_HOST=<your postgresql host>
export PG_PORT=54322
export PG_PASSWORD=<your postgresql db password>
export PG_USER=<your postgresql db username>
```
## Create db table
```sh
cd /path/to/funcchatgptplugin/scripts

psql -h <your postgresql host> -p 5432 -U <postgres username> -d postgres -f /path/to/funcchatgptplugin/scripts/init_pg_vector.sql

```
## Indexes for Postgres
By default, pgvector performs exact nearest neighbor search. To speed up the vector comparison, you may want to create indexes for the embedding column in the documents table. You should do this only after a few thousand records are inserted.

As datastore is using inner product for similarity search, you can add index as follows:
```sh
create index on documents using ivfflat (embedding vector_ip_ops) with (lists = 100);
```
To choose lists constant - a good place to start is records / 1000 for up to 1M records and sqrt(records) for over 1M records
For more information about indexes see [pgvector docs](https://github.com/pgvector/pgvector#indexing)

## Insert records 
The scripts folder contains scripts to batch upsert or process text documents from different data sources, such as a zip file, JSON file, or JSONL file. These scripts use the plugin's upsert utility functions to upload the documents and their metadata to the vector database, after converting them to plain text and splitting them into chunks. Each script folder has a README file that explains how to use it and what parameters it requires.
Refer here to insert [records](https://github.com/openai/chatgpt-retrieval-plugin/tree/main#scripts)

## Create Azure Functions on ACA app

```sh
az login
  
az account set -subscription | -s <subscription_name>

az upgrade

az extension add --name containerapp --upgrade

az provider register --namespace Microsoft.Web

az provider register --namespace Microsoft.App

az provider register --namespace Microsoft.OperationalInsights

az group create --name MyResourceGroup --location northeurope

az containerapp env create -n MyContainerappEnvironment -g MyResourceGroup --location northeurope

az storage account create --name <STORAGE_NAME> --location northeurope --resource-group MyResourceGroup --sku Standard_LRS

az functionapp create --resource-group MyResourceGroup --name <functionapp_name> \
--environment MyContainerappEnvironment \
--storage-account <Storage_name> \
--functions-version 4 \
--image <DOCKER_ID>/<your_funcchatgptplugin_image_name>:<version> 
```
**Set required function app settings**

Create a [bearer](https://github.com/openai/chatgpt-retrieval-plugin/tree/main#general-environment-variables) token

``` sh
az functionapp config appsettings set --name <app_name> --resource-group <Resource_group> --settings
DATASTORE="<your_datastore>"
BEARER_TOKEN="<your_bearer_token>"
OPENAI_API_KEY="<your_openai_api_key>"
OPENAI_API_BASE="https://<AzureOpenAIName>.openai.azure.com/"
OPENAI_API_TYPE="azure"
OPENAI_EMBEDDINGMODEL_DEPLOYMENTID="<Name of text-embedding-ada-002 model deployment>"
OPENAI_METADATA_EXTRACTIONMODEL_DEPLOYMENTID="<Name of deployment of model for metatdata>"
OPENAI_COMPLETIONMODEL_DEPLOYMENTID="<Name of general model deployment used for completion>"
PG_HOST="<postgres_host>"
PG_PORT="<postgres_port>"
PG_USER="<postgres_user>"
PG_PASSWORD="<postgres_password>"
PG_DATABASE="<postgres_database>"

```
Alternatively the function app settings can be configured using Azure Portal Go to Functions resource -> Configuration -> edit a new app setting -> click on Apply
![image](https://github.com/raorugan/funcchatgptplugin/assets/45637559/f3dec3d7-2bd2-48ee-8261-6dccd25b7553)


Congratulations you have now completed the setup. The plugin should be hosted successfully on Functions on Azure Container apps and gets executed when the query is posted.

You can test the deployment by 
```sh
az functionapp function show -g <Resource_group> -n  <function_app_name>  --function-name <chatgptplugin_funtion_name> --query "invokeUrlTemplate" --output tsv
```
Copy the complete **Invoke URL** shown in the output of the publish command into a browser address bar, appending with .well-known/openapi.yaml
```sh
https://<<functions_host_url>/.well-known/openapi.yaml
```
## Local Testing the Function ChatGPT Plugin

You can use to sample-payload.py in this repo to test the plugin. Update the url with your function host url and post the query of your choice
```sh
python sample-payload.py
data = {
   "queries" : [
       {
            "query": "Where is the Todo list?"  ,
            "top_k"  : 1
            
        }
   ]
   
}
Output - pathtothefile/ToDoList.txt
```
## Testing with ChatGPT

Visit [ChatGPT](https://chat.openai.com/), select "Plugins" from the model picker, click on the plugins picker, and click on "Plugin store" at the bottom of the list.

Choose "Develop your own plugin" and enter your function host URL  when prompted.

Your Function chatGPT plugin is now enabled for your ChatGPT session.

For more information, refer to the [OpenAI documentation](https://platform.openai.com/docs/plugins/getting-started/openapi-definition)


## References
[Chatgpt plugin repo](https://github.com/openai/chatgpt-retrieval-plugin/tree/main#chatgpt-retrieval-plugin)
