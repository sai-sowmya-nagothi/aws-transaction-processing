import json
import os
import time
from datetime import datetime, timezone
 
print("Transaction processing started")
 
raw_transaction = os.environ.get("TRANSACTION_JSON")
 
if not raw_transaction:
    raise ValueError("TRANSACTION_JSON environment variable is missing")
 
transaction = json.loads(raw_transaction)
transaction["status"] = "processing"
 
print(json.dumps(transaction))
 
time.sleep(5)
 
transaction["status"] = "processed"
transaction["processed_at"] = datetime.now(timezone.utc).isoformat()
 
print(json.dumps(transaction))
print("Transaction processing completed successfully")
