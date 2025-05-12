import json
import boto3
import os

s3 = boto3.client('s3')
FINAL_BUCKET = os.environ['FINAL_BUCKET']

def handler(event, context):
    print("Event received:", json.dumps(event))

    for record in event['Records']:
        src_bucket = record['s3']['bucket']['name']
        src_key = record['s3']['object']['key']

        new_key = f"processed/{src_key.split('/')[-1]}"

        # Copy to final bucket
        s3.copy_object(
            CopySource={'Bucket': src_bucket, 'Key': src_key},
            Bucket=FINAL_BUCKET,
            Key=new_key
        )

        # Delete from landing bucket
        s3.delete_object(Bucket=src_bucket, Key=src_key)

        print(f"Moved {src_key} to {FINAL_BUCKET}/{new_key}")

    return {
        'statusCode': 200,
        'body': json.dumps('Moved successfully')
    }