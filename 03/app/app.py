from flask import Flask
import pyodbc

app = Flask(__name__)

# Configura la conexión a la base de datos
config = {
    'driver': '{ODBC Driver 17 for SQL Server}',
    'server': 'jga.database.windows.net',
    'database': 'coches',
    'uid': 'jga',
    'pwd': '1234!Strong',
    'Encrypt': 'yes',
    'TrustServerCertificate': 'no',
    'Connection Timeout': 30
}

# Intenta establecer la conexión a la base de datos
try:
    conn_str = ";".join([f"{key}={value}" for key, value in config.items()])
    conn = pyodbc.connect(conn_str)
    print("Conexión exitosa a la base de datos")

    # Crea un cursor para ejecutar consultas
    cursor = conn.cursor()

    # Definimos la ruta "/" para la página principal
    @app.route("/")
    def index():
        # Ejecuta una consulta para obtener los datos de coches
        cursor.execute("SELECT * FROM coches")

        # Obtiene los resultados de la consulta
        results = cursor.fetchall()

        # Construye la respuesta en formato HTML
        response = "<h1>Datos de coches:</h1>"
        for row in results:
            response += f"<p>ID: {row[0]}, Marca: {row[1]}, Modelo: {row[2]}, Año: {row[3]}</p>"

        return response

    # Cierra el cursor y la conexión al finalizar la petición
    @app.teardown_appcontext
    def close_connection(exception):
        cursor.close()
        conn.close()
        print("Conexión cerrada.")

except pyodbc.Error as error:
    print(f"Error al obtener los datos de coches: {error}")

if __name__ == "__main__":
    app.run()
