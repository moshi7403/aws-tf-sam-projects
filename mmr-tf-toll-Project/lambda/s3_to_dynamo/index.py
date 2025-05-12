import boto3
import os
import json

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def handler(event, context):
    print("Event:", json.dumps(event))

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        response = s3.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read().decode('utf-8')

        for line in content.strip().split("\n"):
            if not line:
                continue
            try:
                item = json.loads(line)
                table.put_item(Item=item)
                print(f"Inserted: {item}")
            except Exception as e:
                print(f"Failed to insert: {line} — Error: {e}")

    return {
        'statusCode': 200,
        'body': json.dumps('Done')
    }