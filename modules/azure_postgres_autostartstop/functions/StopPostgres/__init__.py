import datetime
import logging
import os
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.mgmt.postgresqlflexibleservers import PostgreSQLManagementClient
from shared.holiday_check import is_holiday


def main(stoppostgrestimer: func.TimerRequest) -> None:

    if is_holiday():
        logging.info("Today is a holiday. Skipping PostgreSQL Flexible Server stop operation.")
        return

    SUBSCRIPTION_ID = os.environ["AZURE_SUBSCRIPTION_ID"]
    POSTGRES_RESOURCE_GROUP = os.environ["POSTGRES_RESOURCE_GROUP"]
    POSTGRES_SERVER_NAME = os.environ["POSTGRES_SERVER_NAME"]

    client = PostgreSQLManagementClient(credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID)

    utc_timestamp = datetime.datetime.utcnow().replace(
        tzinfo=datetime.timezone.utc).isoformat()

    poller = client.servers.begin_stop(
        resource_group_name=POSTGRES_RESOURCE_GROUP,
        server_name=POSTGRES_SERVER_NAME,
    )
    if poller.done():
        logging.info(f"Stopped PostgreSQL Flexible Server {POSTGRES_SERVER_NAME}: {POSTGRES_RESOURCE_GROUP}...")

    logging.info(f"Python timer trigger function ran {utc_timestamp}")
