import os
import psycopg2
import pymysql
from pymongo import MongoClient

# Fetch database connection details from environment variables
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

MYSQL_HOST = os.getenv("MYSQL_HOST")
MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3306"))
MYSQL_DB = os.getenv("MYSQL_DB")
MYSQL_USER = os.getenv("MYSQL_USER")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")

MONGO_URI = os.getenv("MONGO_URI")
MONGO_DB = os.getenv("MONGO_DB", "test")
MONGO_COLLECTION = os.getenv("MONGO_COLLECTION", "test_table")

SAMPLE_DATA = [
    ("Alice Smith", "alice.smith@example.com"),
    ("Bob Johnson", "bob.johnson@example.com"),
    ("Eve Adams", "eve.adams@example.com"),
]

CREATE_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS test_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""

INSERT_DATA_SQL = """
INSERT INTO test_table (name, email) VALUES (%s, %s);
"""

def insert_postgres():
    if not all([DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD]):
        print("Skipping PostgreSQL: Missing required environment variables.")
        return
    
    try:
        conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, database=DB_NAME, user=DB_USER, password=DB_PASSWORD
        )
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute(CREATE_TABLE_SQL)
        cur.executemany(INSERT_DATA_SQL, SAMPLE_DATA)
        print("Inserted into PostgreSQL.")
    except Exception as e:
        print("PostgreSQL Error:", e)
    finally:
        cur.close()
        conn.close()

def insert_mysql():
    if not all([MYSQL_HOST, MYSQL_DB, MYSQL_USER, MYSQL_PASSWORD]):
        print("Skipping MySQL: Missing required environment variables.")
        return

    try:
        conn = pymysql.connect(
            host=MYSQL_HOST, port=MYSQL_PORT, database=MYSQL_DB,
            user=MYSQL_USER, password=MYSQL_PASSWORD, autocommit=True
        )
        cur = conn.cursor()
        cur.execute(CREATE_TABLE_SQL.replace("SERIAL", "INT AUTO_INCREMENT"))  # Adjust for MySQL
        cur.executemany(INSERT_DATA_SQL, SAMPLE_DATA)
        print("Inserted into MySQL.")
    except Exception as e:
        print("MySQL Error:", e)
    finally:
        cur.close()
        conn.close()

def insert_mongo():
    if not MONGO_URI:
        print("Skipping MongoDB: Missing required environment variable MONGO_URI.")
        return

    try:
        client = MongoClient(MONGO_URI)
        db = client[MONGO_DB]
        collection = db[MONGO_COLLECTION]
        docs = [{"name": name, "email": email} for name, email in SAMPLE_DATA]
        collection.insert_many(docs)
        print("Inserted into MongoDB.")
    except Exception as e:
        print("MongoDB Error:", e)

def main():
    insert_postgres()
    insert_mysql()
    insert_mongo()

if __name__ == "__main__":
    main()
