# src/db_utils.py
import pymysql
import sys

def get_db_connection(db_user, db_pass, db_host, db_name):
    """Establishes a connection to the MySQL database."""
    try:
        connection = pymysql.connect(
            host=db_host,
            user=db_user,
            password=db_pass,
            database=db_name,
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=False
        )
        print(">> Database connection successful.")
        return connection
    except pymysql.Error as e:
        print(f"Error connecting to MySQL Database: {e}", file=sys.stderr)
        return None