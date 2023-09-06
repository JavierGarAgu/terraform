from flask import Flask, render_template
import mysql.connector
import socket
import os

app = Flask(__name__)

# Función para establecer la conexión a la base de datos
def get_db_connection():
    return mysql.connector.connect(
        host=os.environ.get('MYSQLSERVER'),
        user=os.environ.get('MYSQLUSER'),
        password=os.environ.get('MYSQLPASSWD'),
        database=os.environ.get('MYSQLDB'),
    )

@app.route('/')
def mostrar_coches():
    # Utilizar el contexto de with para manejar la conexión a la base de datos
    with get_db_connection() as conexion:
        # Crear un cursor para interactuar con la base de datos
        cursor = conexion.cursor()

        # Ejecutar una consulta para obtener la información de la tabla coches
        consulta = "SELECT coche_id, modelo_id, propietario_id, año_compra, color FROM coches"
        cursor.execute(consulta)

        # Obtener los resultados de la consulta
        resultados = cursor.fetchall()

        # Cerrar cursor
        cursor.close()

    # Obtener el nombre del host
    host = socket.gethostname()

    return render_template('tabla.html', resultados=resultados, host=host)

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
