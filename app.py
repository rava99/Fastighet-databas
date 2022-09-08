from bottle import get, post, run, request, response
import sqlite3
# from urllib import parse as urlparse
from urllib.parse import quote, unquote, parse_qs, urlparse
# from urllib.parse import quote, unquote
from datetime import date


db = sqlite3.connect("db.sqlite")


@post('/reset')
def reset():
    c = db.cursor()
    c.executescript(
        """
			DELETE
			FROM tenants;
			""",
    )

    response.status = 205
    db.commit()
    return {"location": "/"}


@post('/tenants')
def tenants():
    tenants = request.json
    c = db.cursor()
    c.execute(
        """
        	INSERT
        	INTO tenants(tenant_name, personnumber, property_address, property_name, apartment_number)
        	VALUES (?, ?, ?, ?, ?)
			RETURNING tenant_name
        	""",
        [tenants['tenant_name'], tenants['personnumber'],
            tenants['property_address'],  tenants['property_name'], tenants['apartment_number']]
    )
    found = c.fetchone()
    if not found:
        response.status = 400
        return "Illegal..."
    else:
        db.commit()
        response.status = 201
        return {"location": "/tenants/" + quote(tenants['tenant_name'])}
        # curl -X POST http://localhost:8888/tenants -d '{"tenant_name": "Hasse Backman", "personnumber": " 7708094473", "property_address": "Lundavägen 10", "property_name": "Egino 14", "apartment_number": "0001"}' -H "Content-Type: application/json"

# get all the the tenants from the database
# curl -X GET http://localhost:8888/tenants
@get('/tenants')
def get_tenants():
    c = db.cursor()
    c.execute(
        """
		SELECT tenant_name, personnumber, property_address, property_name, apartment_number
		FROM tenants
		""",
    )
    found = [{"tenant_name": tenant_name, "personnumber": personnumber, "property_address": property_address, "property_name": property_name, "apartment_number": apartment_number}
             for tenant_name, personnumber, property_address, property_name, apartment_number in c]
    response.status = 200
    return {"data": found}

# get all the errorreports made by a certain person
# curl -X GET http://localhost:8888/tenants/9906075512/errorReports
@get('/tenants/<personnumber>/errorReports') 
def get_errorReport_for_tenant(personnumber):
    c = db.cursor()
    c.execute(
        """
        SELECT tenant_name, personnumber, information
        FROM errorReports
        WHERE personnumber = ?
        """,
        [unquote(personnumber)]
    )
    items = c.fetchall()
    if not items:
        response.status = 404
        return {"data": []}
    else:
        found = [{"tenants name": tenant_name, "personnumber": personnumber, "information": information}
                 for tenant_name, personnumber, information in items]
        response.status = 200
        return {"data": found}

# get all the the apartments from the database
# curl -X GET http://localhost:8888/apartments
@get('/apartments')
def get_apartments():
    c = db.cursor()
    c.execute(
        """
		SELECT property_name, property_address, apartment_number, end_of_contract_date, is_terminated
		FROM apartments
		""",
    )
    found = [{"property_name": property_name, "property_address": property_address, "apartment_number": apartment_number, "end_of_contract_date": end_of_contract_date, "is_terminated": is_terminated}
             for property_name, property_address, apartment_number, end_of_contract_date, is_terminated in c]
    response.status = 200
    return {"data": found}

# get all the upcoming vacant apartments between given dates in a property    
# curl -X GET http://localhost:8888/apartments/Egino14/vacant\?after=2021-02-21\&before=2022-12-05
@get('/apartments/<property_name>/vacant')
def get_vacancy(property_name):
    c = db.cursor()
    query = """
		SELECT end_of_contract_date, apartment_number
		FROM apartments
		WHERE is_terminated = 1
		"""
    params = []
    query += " AND property_name = ?"
    params.append(unquote(property_name))
    if request.query.before:
        query += " AND end_of_contract_date < ?"
        params.append(unquote(request.query.before))
    if request.query.after:
        query += " AND end_of_contract_date > ?"
        params.append(unquote(request.query.after))

    c.execute(query, params)
    db.commit()
    found = [{"end_of_contract_date": end_of_contract_date, "apartment_number": apartment_number}
             for end_of_contract_date, apartment_number in c]
    response.status = 200
    return {"data": found}

# # terminate contract of an apartment and give date for end of contract
# curl -X POST http://localhost:8888/apartments/Panelgatan5/1001/terminate
@post('/apartments/<property_address>/<apartment_number>/terminate')
def terminate_contract(property_address, apartment_number):
    c = db.cursor()
    c.execute( """
        UPDATE apartments
        SET is_terminated = 1,
            end_of_contract_date = "2023-03-01"
        WHERE property_address = ?
        AND apartment_number = ?
        """,
        [unquote(property_address), unquote(apartment_number)]
    )

    db.commit()
    response.status = 205
    return {"data": ""}



run(reloader=True, host='localhost', port=8888)
