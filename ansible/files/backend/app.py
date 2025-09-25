from flask import Flask, jsonify, request
import os, psycopg

app = Flask(__name__)
DATABASE_URL = os.environ["DATABASE_URL"]

def get_conn():
    return psycopg.connect(DATABASE_URL)

@app.get("/health")
def health():
    return jsonify(ok=True)

@app.post("/items")
def create_item():
    data = request.get_json(force=True)
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("CREATE TABLE IF NOT EXISTS items(id serial primary key, name text);")
        cur.execute("INSERT INTO items(name) VALUES (%s) RETURNING id;", (data["name"],))
        return jsonify(id=cur.fetchone()[0]), 201

@app.get("/items")
def list_items():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("CREATE TABLE IF NOT EXISTS items(id serial primary key, name text);")
        cur.execute("SELECT id, name FROM items ORDER BY id;")
        return jsonify([{"id": r[0], "name": r[1]} for r in cur.fetchall()])

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)