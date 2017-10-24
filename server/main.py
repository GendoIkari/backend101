from flask import Flask, jsonify, request
import time

app = Flask(__name__)

STORE_MESSAGES = []

@app.route('/v1/messages', methods=['GET'])
def messages():
    return jsonify({'messages': STORE_MESSAGES})

@app.route('/v1/messages', methods=['POST'])
def create_message():
    json = request.get_json()
    new_message = {
        'id': len(STORE_MESSAGES),
        'sender': json['sender'],
        'content': json['content'],
        'timestamp': time.time(),
    }
    STORE_MESSAGES.append(new_message)
    return jsonify(new_message)
