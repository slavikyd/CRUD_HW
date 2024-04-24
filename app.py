"""Crud hw flask server."""
from flask import request
from psycopg2 import OperationalError
from psycopg2.sql import SQL, Literal

import dbquery
import http_code
from creds import FLASK_PORT, app, connection
from extras import WELCOME_PAGE, body_check

connection.autocommit = True


@app.get('/')
def welcomingpage():
    """Welcome page handler.

    Returns:
        str: html string of welcome page
    """
    return WELCOME_PAGE


@app.get('/conferences')
def get_conferences():
    """Get request handler for conferences.

    Returns:
        cursor: in fetchall state
        int: http-code answer
    """
    try:
        with connection.cursor() as cursor:
            cursor.execute(dbquery.QUERY_GET_CONFS)
            return cursor.fetchall(), http_code.OK
    except OperationalError:
        return http_code.SERVER_ERROR


@app.post('/conferences/create')
def create_conference():
    """Post request handler for conferences.

    Returns:
        str: empty string
        int: http-code answer
    """
    body = request.json

    title = body['title']
    held_date = body['held_date']
    address = body['address']

    query = SQL(dbquery.QUERY_CONFS_CREATE).format(
        title=Literal(title),
        held_date=Literal(held_date),
        address=Literal(address),
        )

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchone()

    return result, http_code.OK


@app.post('/conferences/update')
def update_conferences():
    """Post request handler used to update conferences.

    Returns:
        str: empty string
        int: http-code answre
    """
    body = request.json

    id_ = body['id']
    title = body['title']
    held_date = body['held_date']
    address = body['adress']

    body_check(body, [title, held_date, address])

    query = SQL().format(
        title=Literal(title),
        held_date=Literal(held_date),
        address=Literal(address),
        id=Literal(id_),
        )

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    if len(result) == 0:
        return '', http_code.NOT_FOUND

    return '', http_code.NO_CONTENT


@app.delete('/conferences/delete')
def delete_conference():
    """Post request handler used to delete conferences and links.

    Returns:
        str: empty str
        int: http-code answer
    """
    body = request.json

    id_ = body['id']

    delete_conference_links = SQL(dbquery.QUERY_DELETE_CONF_LINKS).format(id=Literal(id_))
    delete_conference = SQL(dbquery.QUERY_DELETE_CONF).format(id=Literal(id_))

    with connection.cursor() as cursor:
        cursor.execute(delete_conference_links)
        cursor.execute(delete_conference)
        result = cursor.fetchall()

    if len(result) == 0:
        return '', http_code.NOT_FOUND

    return '', http_code.NO_CONTENT


if __name__ == '__main__':
    app.run(port=FLASK_PORT)
