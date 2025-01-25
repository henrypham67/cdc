import os
import psycopg2

# Fetch database connection details from environment variables
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432")  # Default port is 5432 if not set
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# Sample data to insert
SAMPLE_DATA = [
    ("Alice Smith", "alice.smith@example.com"),
    ("Bob Johnson", "bob.johnson@example.com"),
    ("Charlie Brown", "charlie.brown@example.com"),
    ("Diana Prince", "diana.prince@example.com"),
    ("Eve Adams", "eve.adams@example.com"),
]

# SQL commands
CREATE_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS test_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""

INSERT_DATA_SQL = """
INSERT INTO test_table (name, email)
VALUES (%s, %s);
"""

def main():
    try:
        # Validate environment variables
        if not all([DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD]):
            raise ValueError("Missing required database connection environment variables.")

        # Connect to the PostgreSQL database
        print("Connecting to the database...")
        connection = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
        )
        connection.autocommit = True  # Enable autocommit for immediate writes

        # Create a cursor object
        cursor = connection.cursor()

        # Create the table if it doesn't exist
        print("Creating the table...")
        cursor.execute(CREATE_TABLE_SQL)

        # Insert sample data
        print("Inserting sample data...")
        cursor.executemany(INSERT_DATA_SQL, SAMPLE_DATA)

        # Verify the inserted data
        print("Verifying the data...")
        cursor.execute("SELECT * FROM test_table;")
        rows = cursor.fetchall()
        for row in rows:
            print(row)

    except Exception as e:
        print("Error:", e)
    finally:
        # Close the cursor and connection
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'connection' in locals() and connection:
            connection.close()
        print("Database connection closed.")

if __name__ == "__main__":
    main()
