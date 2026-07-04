import boto3
import csv
import io
import json
import os
import urllib.parse
 
s3 = boto3.client("s3")
stepfunctions = boto3.client("stepfunctions")
 
STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]
 
 
def lambda_handler(event, context):
    processed = 0
 
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
 
        print(f"Processing file: s3://{bucket}/{key}")
 
        response = s3.get_object(Bucket=bucket, Key=key)
        content = response["Body"].read().decode("utf-8-sig")
 
        reader = csv.DictReader(io.StringIO(content))
 
        for row in reader:
            transaction = {
                key: value
                for key, value in row.items()
                if key is not None and value not in (None, "")
            }
 
            print(f"Starting transaction: {json.dumps(transaction)}")
 
            stepfunctions.start_execution(
                stateMachineArn=STATE_MACHINE_ARN,
                input=json.dumps(transaction)
            )
 
            processed += 1
 
    return {
        "statusCode": 200,
        "processedTransactions": processed
    }
