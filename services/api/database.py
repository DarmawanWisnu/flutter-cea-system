import psycopg2
import psycopg2.pool
import os
from dotenv import load_dotenv

env_path = os.path.join(os.path.dirname(__file__), ".env")
load_dotenv(dotenv_path=env_path)

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "fountaine")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_PORT = int(os.getenv("DB_PORT", "5432"))

print("DEBUG ENV → HOST:", DB_HOST)
print("DEBUG ENV → USER:", DB_USER)

_pool = None

def init_pool():
    global _pool
    if _pool is None:
        _pool = psycopg2.pool.SimpleConnectionPool(
            minconn=1,
            maxconn=10,
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            port=DB_PORT,
        )
        print(f"[DB] Pool connected → {DB_HOST}:{DB_PORT}/{DB_NAME}")

def get_connection():
    if _pool is None:
        init_pool()
    return _pool.getconn()

def release_connection(conn):
    if _pool and conn:
        _pool.putconn(conn)
