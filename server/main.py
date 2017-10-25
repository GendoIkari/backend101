from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
import time

app = Flask(__name__)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///chat.db'
db = SQLAlchemy(app)

class Message(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    sender = db.Column(db.String, nullable=False)
    content = db.Column(db.String, nullable=False)
    timestamp = db.Column(db.Integer, nullable=False)

    def json(self):
        return {'id': self.id, 'sender': self.sender, 'content': self.content, 'timestamp': self.timestamp}

db.create_all()

@app.route('/v1/messages', methods=['GET'])
def messages():
    messages = [m.json() for m in Message.query.all()]
    return jsonify({'messages': messages})

@app.route('/v1/messages', methods=['POST'])
def create_message():
    json = request.get_json()
    new_message = Message(
        sender=json['sender'],
        content=json['content'],
        timestamp=time.time(),
    )
    db.session.add(new_message)
    db.session.commit()
    return jsonify(new_message.json())
