from flask import Flask, jsonify
import os
import requests
from base64 import b64encode

app = Flask(__name__)

RPC_USER = os.getenv("RPC_USER", "user")
RPC_PASSWORD = os.getenv("RPC_PASSWORD", "pass")
RPC_PORT = int(os.getenv("RPC_PORT", 18443))

def rpc(method, params=None):
    body = {"jsonrpc": "1.0", "id": "dash", "method": method, "params": params or []}
    auth = b64encode(f"{RPC_USER}:{RPC_PASSWORD}".encode()).decode()
    r = requests.post(f"http://bitcoind:{RPC_PORT}", json=body, headers={"Authorization": f"Basic {auth}"})
    r.raise_for_status()
    return r.json()["result"]

@app.route("/")
def index():
    blockcount = rpc("getblockcount")
    difficulty = rpc("getdifficulty")
    best_block_hash = rpc("getbestblockhash")
    return jsonify({
        "block_count": blockcount,
        "difficulty": difficulty,
        "best_block": best_block_hash
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)