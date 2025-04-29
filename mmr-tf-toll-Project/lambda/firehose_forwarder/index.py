import json
import boto3
import os

firehose = boto3.client('firehose')
stream_name = os.environ['FIREHOSE_STREAM_NAME']

def handler(event, context):
    print("Received event:", event)

    if "body" in event:
        payload = event["body"]
        response = firehose.put_record(
            DeliveryStreamName=stream_name,
            Record={'Data': payload.encode('utf-8')}
        )
        print("Firehose response:", response)

    return {
        'statusCode': 200,
        'body': json.dumps('Data sent to Firehose')
    }