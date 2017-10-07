# ----- Imports ----- #

from flask import Flask


# ----- Setup ----- #

app = Flask(__name__)


# ----- Routes ----- #

@app.route('/')
def main():

    return 'hello world'
