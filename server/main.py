from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
import time

app = Flask(__name__)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///chat.db'
db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String, nullable=False, unique=True)
    password = db.Column(db.String, nullable=False)
    messages = db.relationship('Message', backref='sender', lazy=True)

    def json(self):
        return {'id': self.id, 'name': self.name}

class Message(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    sender_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    content = db.Column(db.String, nullable=False)
    timestamp = db.Column(db.Integer, nullable=False)

    def json(self):
        return {'id': self.id, 'sender': self.sender.name, 'content': self.content, 'timestamp': self.timestamp}

db.create_all()

@app.route('/v1/messages', methods=['GET'])
def messages():
    messages = [m.json() for m in Message.query.all()]
    return jsonify({'messages': messages})

@app.route('/v1/messages', methods=['POST'])
def create_message():
    auth = request.authorization
    json = request.get_json()

    user = User.query.filter(User.name == auth.username).one()
    if not check_password_hash(user.password, auth.password):
        return 401

    new_message = Message(
        sender=user,
        content=json['content'],
        timestamp=time.time(),
    )
    db.session.add(new_message)
    db.session.commit()
    return jsonify(new_message.json())

@app.route('/v1/users', methods=['POST'])
def create_user():
    json = request.get_json()

    n = User.query.filter(User.name == json['name']).count()
    if (n):
        return jsonify({})

    new_user = User(
        name=json['name'],
        password=generate_password_hash(json['password']),
    )
    db.session.add(new_user)
    db.session.commit()
    return jsonify(new_user.json())
