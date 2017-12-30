# ----- Imports ----- #

import uuid
from tinydb import TinyDB, where


# ----- Setup ----- #

DB_FILE = 'lights.json'


# ----- Functions ----- #

def _open_db(table_name):

    """Wrapper, opens a db json file and returns the connection."""

    def decorator(func):

        def wrapper(*args, **kwargs):

            db = TinyDB(DB_FILE)
            return func(db.table(table_name), *args, **kwargs)

        return wrapper

    return decorator


@_open_db('groups')
def get_groups(db):

    return db.all()


@_open_db('groups')
def add_group(db, name, lights):

    """Adds a light to the database."""

    record = {'id': str(uuid.uuid4()), 'name': name, 'lights': lights}
    db.insert(record)

    return record['id']
