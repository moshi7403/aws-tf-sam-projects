import json
import boto3
import os
import base64

firehose = boto3.client('firehose')
stream_name = os.environ['FIREHOSE_STREAM_NAME']

def handler(event, context):
    if "body" in event:
        body = event["body"]
        if event.get("isBase64Encoded", False):
            body = base64.b64decode(body).decode('utf-8')

        try:
            payload = json.loads(body)
        except Exception as e:
            print(f"Invalid JSON: {e}")
            return {'statusCode': 400, 'body': 'Invalid JSON'}

        final_payload = json.dumps(payload) + "\n"

        try:
            firehose.put_record(
                DeliveryStreamName=stream_name,
                Record={'Data': final_payload.encode('utf-8')}
            )
        except Exception as e:
            print(f"PutRecord failed: {e}")

    return {'statusCode': 200, 'body': 'OK'}