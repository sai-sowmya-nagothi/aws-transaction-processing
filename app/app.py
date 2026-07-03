from flask import Flask, jsonify, request
import uuid
from datetime import datetime
 
app = Flask(__name__)
 
transactions = []
 
@app.route("/")
def home():
    return jsonify({
        "service": "AWS Transaction Processing API",
        "status": "running"
    })
 
@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200
 
@app.route("/transactions", methods=["POST"])
def create_transaction():
    data = request.get_json() or {}
 
    transaction = {
        "id": str(uuid.uuid4()),
        "amount": data.get("amount"),
        "type": data.get("type"),
        "status": "processed",
        "created_at": datetime.utcnow().isoformat()
    }
 
    transactions.append(transaction)
    return jsonify(transaction), 201
 
@app.route("/transactions", methods=["GET"])
def get_transactions():
    return jsonify(transactions)
 
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
