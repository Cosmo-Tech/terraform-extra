import datetime
import logging
import os

import requests


def trigger_slack_alert(server_name: str, resource_group: str, action: str, error_details: str) -> None:
    """Post a formatted alert message to a Slack Incoming Webhook"""
    webhook_url = os.environ.get("SLACK_WEBHOOK_URL")

    if not webhook_url:
        logging.info("SLACK_WEBHOOK_URL not configured. Skipping failure alert.")
        return

    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

    payload = {
            "text": f"🚨 *PostgreSQL Auto-({action}) Failed*",
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": "🚨 Azure Function Action Failed",
                        "emoji": True
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {"type": "mrkdwn", "text": f"*Postgres Server Name:*\n`{server_name}`"},
                        {"type": "mrkdwn", "text": f"*Resource Group:*\n`{resource_group}`"},
                        {"type": "mrkdwn", "text": f"*Action:*\n`{action}`"},
                        {"type": "mrkdwn", "text": f"*Time (UTC):*\n`{timestamp}`"}
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"*Error Details:*\n```{error_details[:1000]}```"
                    }
                }
            ]
        }
    try:
        response = requests.post(webhook_url, json=payload, timeout=10)
        response.raise_for_status()
        logging.info("Failure alert successfully posted to Slack.")
    except Exception as e:
        logging.error(f"Failed to post the failure alert to Slack: {e}")
