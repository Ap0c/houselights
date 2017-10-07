# ----- Imports ----- #

from flask import Flask
from api import api
import db


# ----- Setup ----- #

app = Flask(__name__)
app.register_blueprint(api, url_prefix='/api')
db.setup_db()


# ----- Routes ----- #

@app.route('/')
def main():

    return 'hello world'
