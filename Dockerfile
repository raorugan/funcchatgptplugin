
FROM python:3.10 as requirements-stage

WORKDIR /tmp

RUN pip install --upgrade pip
RUN pip install poetry

COPY ./pyproject.toml ./poetry.lock* /tmp/


RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

#FROM python:3.10
FROM mcr.microsoft.com/azure-functions/python:4-python3.10

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true\
    AzureWebJobsFeatureFlags=EnableWorkerIndexing

#WORKDIR /code

RUN apt-get update && apt-get -y install libpq-dev gcc

COPY --from=requirements-stage /tmp/requirements.txt requirements.txt
#RUN pip install --upgrade pip




RUN python3 -m pip install  -r requirements.txt

COPY . /home/site/wwwroot

#COPY . /code/

# Heroku uses PORT, Azure App Services uses WEBSITES_PORT, Fly.io uses 8080 by default
#CMD ["sh", "-c", "uvicorn server.main:app --host 0.0.0.0 --port ${PORT:-${WEBSITES_PORT:-8080}}"]
