import datetime
import logging
import os
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.mgmt.postgresqlflexibleservers import PostgreSQLManagementClient
from shared.holiday_check import is_holiday
from shared.alert import trigger_slack_alert


def main(startpostgrestimer: func.TimerRequest) -> None:

    if is_holiday():
        logging.info("Today is a holiday. Skipping PostgreSQL Flexible Server start operation.")
        return

    SUBSCRIPTION_ID = os.environ["AZURE_SUBSCRIPTION_ID"]
    POSTGRES_RESOURCE_GROUP = os.environ["POSTGRES_RESOURCE_GROUP"]
    POSTGRES_SERVER_NAME = os.environ["POSTGRES_SERVER_NAME"]

    utc_timestamp = datetime.datetime.now(datetime.timezone.utc).isoformat()

    try:
        client = PostgreSQLManagementClient(credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID)
        poller = client.servers.begin_start(
            resource_group_name=POSTGRES_RESOURCE_GROUP,
            server_name=POSTGRES_SERVER_NAME,
        )
        poller.result()
        logging.info(f"Successfully started PostgreSQL Flexible Server {POSTGRES_SERVER_NAME}: {POSTGRES_RESOURCE_GROUP}...")
    except Exception as err:
        logging.error(f"Error while starting PostgreSQL Flexible Server {POSTGRES_SERVER_NAME}: {err}")

        trigger_slack_alert(
            server_name=POSTGRES_SERVER_NAME,
            resource_group=POSTGRES_RESOURCE_GROUP,
            action="Start Postgres Flexible Server",
            error_details=str(err),
        )
        raise

    logging.info(f"Python timer trigger function ran at {utc_timestamp}")


