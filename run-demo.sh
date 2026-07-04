#!/bin/bash
set -e
 
BUCKET="transaction-input-cd2bb783b53fddb0e29e6b231d"
STATE_MACHINE_ARN="arn:aws:states:us-east-1:239359658333:stateMachine:transaction-processing-workflow"
 
echo "Uploading transactions..."
aws s3 cp test-transactions.csv \
  "s3://$BUCKET/test-transactions-$(date +%Y%m%d-%H%M%S).csv"
 
echo "Transactions started. Waiting 60 seconds for processing..."
sleep 60
 
echo
printf "%-15s %-12s %-32s %-32s\n" \
  "TRANSACTION" "STATUS" "STARTED" "STOPPED"
 
for ARN in $(aws stepfunctions list-executions \
  --state-machine-arn "$STATE_MACHINE_ARN" \
  --max-results 3 \
  --query 'executions[].executionArn' \
  --output text); do
 
  DATA=$(aws stepfunctions describe-execution \
    --execution-arn "$ARN" \
    --query '[input,status,startDate,stopDate]' \
    --output json)
 
  TXN=$(echo "$DATA" | python3 -c \
    'import sys,json; d=json.load(sys.stdin); print(json.loads(d[0]).get("transaction_id","UNKNOWN"))')
 
  STATUS=$(echo "$DATA" | python3 -c \
    'import sys,json; print(json.load(sys.stdin)[1])')
 
  STARTED=$(echo "$DATA" | python3 -c \
    'import sys,json; print(json.load(sys.stdin)[2])')
 
  STOPPED=$(echo "$DATA" | python3 -c \
    'import sys,json; print(json.load(sys.stdin)[3] or "-")')
 
  printf "%-15s %-12s %-32s %-32s\n" \
    "$TXN" "$STATUS" "$STARTED" "$STOPPED"
done
 
