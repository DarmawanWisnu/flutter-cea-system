import psycopg2
import psycopg2.pool
import os
from dotenv import load_dotenv

# Load .env
env_path = os.path.join(os.path.dirname(__file__), ".env")
load_dotenv(dotenv_path=env_path)

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "fountaine")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_PORT = int(os.getenv("DB_PORT", "5432"))

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
        print(f"[DB] Pool → {DB_HOST}:{DB_PORT}/{DB_NAME}")


def get_connection():
    if _pool is None:
        init_pool()
    return _pool.getconn()


def release_connection(conn):
    if _pool and conn:
        try:
            _pool.putconn(conn)
        except Exception:
            pass


def run_migrations():
    """
    Fresh, clean schema:
      - kits
      - telemetry (camelCase)
      - actuator_event (camelCase)
    """
    conn = get_connection()
    cur = conn.cursor()

    # KITS TABLE
    cur.execute("""
        CREATE TABLE IF NOT EXISTS kits (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            "createdAt" TIMESTAMPTZ DEFAULT NOW()
        );
    """)

    # TELEMETRY TABLE
    cur.execute("""
        CREATE TABLE IF NOT EXISTS telemetry (
            "rowId" TEXT PRIMARY KEY,
            "deviceId" TEXT NOT NULL,
            "ingestTime" BIGINT NOT NULL,
            "payloadJson" JSONB NOT NULL,
            ppm FLOAT,
            ph FLOAT,
            "tempC" FLOAT,
            humidity FLOAT,
            "waterTemp" FLOAT,
            "waterLevel" FLOAT,
            "payloadHash" TEXT UNIQUE
        );
    """)

    # ACTUATOR TABLE
    cur.execute("""
        CREATE TABLE IF NOT EXISTS actuator_event (
            id SERIAL PRIMARY KEY,
            "deviceId" TEXT NOT NULL,
            "ingestTime" BIGINT NOT NULL,
            "phUp" INT DEFAULT 0,
            "phDown" INT DEFAULT 0,
            "nutrientAdd" INT DEFAULT 0,
            "valueS" FLOAT DEFAULT 0,
            "manual" INT DEFAULT 0,
            "auto" INT DEFAULT 0,
            "refill" INT DEFAULT 0
        );
    """)

    conn.commit()
    cur.close()
    release_connection(conn)

    print("[DB] Migrations executed.")
