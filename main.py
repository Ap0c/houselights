# ----- Imports ----- #

from flask import Flask
from api import api


# ----- Setup ----- #

app = Flask(__name__)
app.register_blueprint(api, url_prefix='/api')


# ----- Routes ----- #

@app.route('/')
def main():

    return app.send_static_file('index.html')

