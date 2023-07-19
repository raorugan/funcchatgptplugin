 The ChatGPT Retrieval Plugin lets you easily search and find personal or work documents by asking questions in everyday language.
 Follow these steps to quickly set up and run the ChatGPT Retrieval Plugin using Azure Functions on Azure Container Apps :

 -Install Python 3.10, if not already installed.
 Clone the repository: git clone (https://github.com/raorugan/funcchatgptplugin.git)

Navigate to the cloned repository directory: cd /path/to/funcchatgptplugin

Install poetry: pip install poetry

Create a new virtual environment with Python 3.10: poetry env use python3.10

Activate the virtual environment: poetry shell

Install app dependencies: poetry install

Create a [bearer](https://github.com/openai/chatgpt-retrieval-plugin/tree/main#general-environment-variables) token

Set the required environment variables:
```
export DATASTORE=<your_datastore>
export BEARER_TOKEN=<your_bearer_token>
export OPENAI_API_KEY=<your_openai_api_key>

# Optional environment variables used when running Azure OpenAI
export OPENAI_API_BASE=https://<AzureOpenAIName>.openai.azure.com/
export OPENAI_API_TYPE=azure
export OPENAI_EMBEDDINGMODEL_DEPLOYMENTID=<Name of text-embedding-ada-002 model deployment>
export OPENAI_METADATA_EXTRACTIONMODEL_DEPLOYMENTID=<Name of deployment of model for metatdata>
export OPENAI_COMPLETIONMODEL_DEPLOYMENTID=<Name of general model deployment used for completion>
export OPENAI_EMBEDDING_BATCH_SIZE=<Batch size of embedding, for AzureOAI, this value need to be set as 1>

# Postgres
export PG_HOST=<postgres_host>
export PG_PORT=<postgres_port>
export PG_USER=<postgres_user>
export PG_PASSWORD=<postgres_password>
export PG_DATABASE=<postgres_database>
