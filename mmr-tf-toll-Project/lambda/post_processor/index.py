import json
import boto3
import os
import base64

firehose = boto3.client('firehose')
stream_name = os.environ['FIREHOSE_STREAM_NAME']

def handler(event, context):
    print("Received event:", json.dumps(event))

    if "body" in event:
        body = event["body"]

        if event.get("isBase64Encoded", False):
            # If API Gateway sent base64 data, decode it
            body = base64.b64decode(body).decode('utf-8')

        payload = json.loads(body)  # parse as JSON to ensure it's clean
        final_payload = json.dumps(payload) + "\n"  # Important for Firehose

        response = firehose.put_record(
            DeliveryStreamName=stream_name,
            Record={'Data': final_payload.encode('utf-8')}
        )

        print("Firehose put_record response:", response)

    return {
        'statusCode': 200,
        'body': json.dumps('Data sent to Firehose')
    }