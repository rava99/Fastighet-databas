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


# @post('/ingredients')
# def add_ingredients():
#     ingredient = request.json
#     c = db.cursor()
#     c.execute(
#         """
#         INSERT
#         INTO ingredients(ingredient_name, measure)
#         VALUES(?, ?)
#         """,
#         [ingredient['ingredient'], ingredient['unit']]
#     )
#     db.commit()
#     response.status = 201
#     return {"location": "/ingredients/" + quote(ingredient['ingredient'])}


# @post('/ingredients/<ingredient_name>/deliveries')
# def add_delivery(ingredient_name):
#     delivery = request.json
#     c = db.cursor()
#     c.execute(
#         """
#         UPDATE ingredients
#         SET delivery_date = ?, in_stock = in_stock + ?, delivery_quantity = ?
#         WHERE ingredient_name IS ?
#         """,
#         [delivery['deliveryTime'], delivery['quantity'],
#             delivery['quantity'], ingredient_name]
#     )
#     db.commit()
#     found = c.fetchall()
#     items = [{"ingredient": ingredient_name, "quantity": in_stock, "unit": measure}
#              for ingredient_name, quantity, measure in found]
#     response.status = 201
#     return {"data": items}


# @get('/ingredients')
# def get_ingredients():
#     c = db.cursor()
#     c.execute(
#         """
# 		SELECT ingredient_name, in_stock, measure
# 		FROM ingredients
# 		""",
#     )
#     found = [{"ingredient": ingredient_name, "quantity": in_stock, "unit": measure}
#              for ingredient_name, in_stock, measure in c]
#     response.status = 200
#     return {"data": found}


# @post('/cookies')
# def add_cookies():
#     cookie = request.json
#     c = db.cursor()
#     c.execute(
#         """
#         INSERT
#         INTO cookies(cookie_name)
#         VALUES(?)
#         """,
#         [cookie['name']]
#     )
#     for item in cookie['recipe']:
#         c.execute(
#             """
#             INSERT
#             INTO recipeitems(cookie_name, ingredient_name, quantity)
#             VALUES(?,?,?)
#             """,
#             [cookie['name'], item['ingredient'], item['amount']]
#         )
#     db.commit()
#     response.status = 201
#     return {"location ": "/cookies/" + quote(cookie['name'])}


# @get('/cookies')
# def get_cookies():
#     c = db.cursor()
#     c.execute(
#         """
#         SELECT cookie_name, COUNT(CASE WHEN is_blocked=0 THEN 1 END)
#         FROM pallets
#         GROUP BY cookie_name;
# 		""",
#     )
#     found = [{"name": cookie_name, "pallets": is_blocked}
#              for cookie_name, is_blocked, in c]
#     response.status = 200
#     return {"data": found}


# @get('/cookies/<cookie_name>/recipe') => @get('/tentant/<personnumbere>/errorReports') få ut alla felanmälningar en person gjort
# @get('/janitor/<janitor_personnumber>/properties') få ut vilka fastigheter en janitor ansvarar över, skriv in i readme fil hur man gör
# def get_recipe_for_cookie(cookie_name):
#     c = db.cursor()
#     c.execute(
#         """
#         SELECT ingredient_name, quantity
#         FROM recipeitems
#         WHERE cookie_name = ?
#         """,
#         [unquote(cookie_name)]
#     )
#     items = c.fetchall()
#     if not items:
#         response.status = 404
#         return {"data": []}
#     else:
#         found = [{"ingredient": ingredient_name, "amount": quantity}
#                  for ingredient_name, quantity in items]
#         response.status = 200
#         return {"data": found}


# # @post('/pallets')
# # def pallets():
# #     pallets = request.json
# #     c = db.cursor()
# #     c.execute(
# #         """
# #           INSERT
# #           INTO pallets(cookie_name, production_date)
# #           VALUES (?, ?)
# #           RETURNING pallet_id
# #           """,
# #         [pallets['cookie'], date.today()]
# #     )
# #     found = c.fetchone()
# #     if not found:
# #         response.status = 422
# #         return {"location": ""}
# #     else:
# #         db.commit()
# #         response.status = 201
# #         pallet_id, = found
# #         return {"location": "/pallets/{pallet_id}"}
# #         # curl -X POST http://localhost:8888/pallets -d '{"cookie": "Tango"}' -H


# @get('/pallets')
# def get_pallets():
#     query = """
# 		SELECT production_date, cookie_name, pallet_id, is_blocked
# 		FROM pallets
# 		WHERE 1 = 1
# 		"""
#     params = []
#     if request.query.cookie:
#         query += " AND cookie_name = ?"
#         params.append(unquote(request.query.cookie))
#     if request.query.before:
#         query += " AND production_date < ?"
#         params.append(unquote(request.query.before))
#     if request.query.after:
#         query += " AND production_date > ?"
#         params.append(unquote(request.query.after))

#     c = db.cursor()
#     c.execute(query, params)
#     found = [{"production_date": production_date, "cookie_name": cookie_name, "pallet_id": pallet_id, "is_blocked": is_blocked}
#              for production_date, cookie_name, pallet_id, is_blocked in c]
#     response.status = 200
#     return {"data": found}


# @post('/cookies/<cookie_name>/block') typ isAvailable på om en lägenhet är ledig. Sen man kan ange datum osv.
# def uppdate_block(cookie_name):
#     c = db.cursor()
#     query = """
#         UPDATE pallets
#         SET is_blocked = 1
#         WHERE 1 = 1
#         """
#     params = []
#     query += " AND cookie_name = ?"
#     params.append(unquote(cookie_name))
#     if request.query.before:
#         query += " AND production_date < ?"
#         params.append(unquote(request.query.before))
#     if request.query.after:
#         query += " AND production_date > ?"
#         params.append(unquote(request.query.after))
#     c = db.cursor()
#     c.execute(query, params)

#     db.commit()
#     response.status = 205
#     return {"data": ""}

# # curl -X POST http://localhost:8888/cookies/Hallongrotta/block\?after=2021-02-21\&before=2022-03-11


# @post('/cookies/<cookie_name>/unblock')
# def uppdate_block(cookie_name):
#     c = db.cursor()
#     query = """
#         UPDATE pallets
#         SET is_blocked = 0
#         WHERE 1 = 1
#         """
#     params = []
#     query += " AND cookie_name = ?"
#     params.append(unquote(cookie_name))
#     if request.query.before:
#         query += " AND production_date < ?"
#         params.append(unquote(request.query.before))
#     if request.query.after:
#         query += " AND production_date > ?"
#         params.append(unquote(request.query.after))
#     c = db.cursor()
#     c.execute(query, params)

#     db.commit()
#     response.status = 205
#     return {"data": ""}
# # curl -X POST http://localhost:8888/cookies/Hallongrotta/unblock\?after=2021-02-21\&before=2022-03-11


run(reloader=True, host='localhost', port=8888)