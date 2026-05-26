from flask import Flask, jsonify, request, send_from_directory
import mysql.connector
import os
from flask_cors import CORS
import boto3
import json

def get_mysql_database_secrets():
    region = os.environ.get("AWS_DEFAULT_REGION", os.environ.get("AWS_REGION", "us-east-1"))
    secret_id = os.environ.get("MYSQL_SECRET_NAME", "ritual-roast-mysql-credentials-dev")

    client = boto3.client("secretsmanager", region_name=region)
    get_secret_value_response = client.get_secret_value(SecretId=secret_id)
    secret = json.loads(get_secret_value_response["SecretString"])

    return [
        secret["host"],
        secret["username"],
        secret["password"],
        secret.get("dbname") or os.environ.get("MYSQL_DATABASE_NAME", "ritual_roast"),
        int(secret.get("port", 3306)),
    ]


app = Flask(
    __name__,
    static_folder="ritual_roast/build/static",
    template_folder="ritual_roast/build"
)
CORS(app, resources={r"/*": {"origins": "*"}})

connection = None
cursor = None


def init_db():
    global connection, cursor
    if connection is not None and connection.is_connected():
        return
    secrets = get_mysql_database_secrets()
    connection = mysql.connector.connect(
        host=secrets[0],
        user=secrets[1],
        password=secrets[2],
        database=secrets[3],
        port=secrets[4],
    )
    cursor = connection.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS recipes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            recipe_name VARCHAR(255) NOT NULL,
            description TEXT,
            ingredients TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        """
    )
    connection.commit()


def check_and_reconnect():
    global connection, cursor
    init_db()
    try:
        connection.ping(reconnect=True, attempts=3, delay=2)
    except mysql.connector.Error:
        print("Database connection lost. Fetching updated credentials and reconnecting...")
        connection = None
        cursor = None
        init_db()


@app.route("/health")
def health():
    return "ok", 200


@app.route('/get_recipe', methods=['GET'])
def get_recipes():
    check_and_reconnect()
    query = "SELECT * FROM recipes ORDER BY id DESC;"
    cursor.execute(query)
    rows = cursor.fetchall()

    recipes = []
    for row in rows:
        recipe = {
            'id': row[0],
            'name': row[1],
            'email': row[2],
            'recipe_name': row[3],
            'description': row[4],
            'ingredients': row[5],
            'created_at': str(row[6])
        }
        recipes.append(recipe)
    return jsonify(recipes)


@app.route('/add_recipe', methods=['POST'])
def add_recipe():
    check_and_reconnect()
    data = request.get_json()

    name = data.get('name')
    email = data.get('email')
    recipe_name = data.get('recipe_name')
    description = data.get('description')
    ingredients = data.get('ingredients')

    query = """
        INSERT INTO recipes (name, email, recipe_name, description, ingredients)
        VALUES (%s, %s, %s, %s, %s);
    """
    cursor.execute(query, (name, email, recipe_name, description, ingredients))
    connection.commit()

    return jsonify({'message': 'Recipe added successfully'}), 201


@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def serve(path):
    print(f"Requested path: {path}")
    static_file_path = os.path.join(app.static_folder, path)
    template_file_path = os.path.join(app.template_folder, path)

    if path and os.path.exists(static_file_path):
        print(f"Serving static file: {static_file_path}")
        return send_from_directory(app.static_folder, path)

    if path and os.path.exists(template_file_path):
        print(f"Serving template file: {template_file_path}")
        return send_from_directory(app.template_folder, path)

    index_file = os.path.join(app.template_folder, "index.html")
    if os.path.exists(index_file):
        print(f"Serving React index.html: {index_file}")
        return send_from_directory(app.template_folder, "index.html")

    print("Error: React index.html not found!")
    return "Error: index.html not found!", 404


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
