# ----- Imports ----- #

import sqlite3


# ----- Setup ----- #

DB_FILE = 'lights.db'


# ----- Functions ----- #

def _connection():

    """Creates and returns a database connection."""

    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row

    cur = conn.cursor()

    return conn, cur


def _get_cursor(func):

    """Decorator function, passes cursor to function and closes connection."""

    def wrapper(*args, **kwargs):

        conn, cur = _connection()

        result = func(cur, *args, **kwargs)

        conn.commit()
        conn.close()

        return result

    return wrapper


@_get_cursor
def setup_db(cur):

    """Sets up the tables needed."""

    cur.execute('''
        CREATE TABLE IF NOT EXISTS lights
            ( id INTEGER PRIMARY KEY
            , name TEXT
            , hueId INTEGER
            , rfOn INTEGER
            , rfOff INTEGER
            )
    ''')

