import psycopg2
import psycopg2.pool
import os
from dotenv import load_dotenv
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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
            minconn=5,
            maxconn=50,
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            port=DB_PORT,
        )
        
        logger.info(f"[DB] Pool → {DB_HOST}:{DB_PORT}/{DB_NAME} (max connections: 50)")


def get_connection():
    if _pool is None:
        init_pool()
    return _pool.getconn()


def release_connection(conn):
    if _pool and conn:
        try:
            _pool.putconn(conn)
        except Exception as e:
            logger.warning(f"[DB] Warning: Failed to release connection: {e}")


def run_migrations():
    """
    Fresh, clean schema:
      - kits
      - telemetry (camelCase)
      - actuator_event (camelCase)
      - actuator_cooldown (for cooldown tracking)
      - ml_prediction_log (for ML predictions)
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

    # ACTUATOR COOLDOWN TABLE
    cur.execute("""
        CREATE TABLE IF NOT EXISTS actuator_cooldown (
            id SERIAL PRIMARY KEY,
            "deviceId" TEXT NOT NULL,
            "actionType" TEXT NOT NULL,
            "lastTime" BIGINT NOT NULL,
            "lastValue" FLOAT DEFAULT 0,
            UNIQUE ("deviceId", "actionType")
        );
    """)

    # ML PREDICTION LOG TABLE
    cur.execute("""
        CREATE TABLE IF NOT EXISTS ml_prediction_log (
            id SERIAL PRIMARY KEY,
            "deviceId" TEXT NOT NULL,
            "predictTime" BIGINT NOT NULL,
            "payloadJson" JSONB NOT NULL,
            "predictJson" JSONB NOT NULL
        );
    """)

    # DEVICE MODE TABLE (per-user, per-device auto/manual tracking)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS device_mode (
            id SERIAL PRIMARY KEY,
            "userId" TEXT NOT NULL,
            "deviceId" TEXT NOT NULL,
            "autoMode" BOOLEAN DEFAULT FALSE,
            "updatedAt" TIMESTAMPTZ DEFAULT NOW(),
            UNIQUE ("userId", "deviceId"),
            CHECK (LENGTH("userId") >= 8),
            CHECK (LENGTH("deviceId") >= 5),
            CHECK ("userId" != ''),
            CHECK ("deviceId" != '')
        );
    """)

    # USER PREFERENCE TABLE (selected kit per user)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS user_preference (
            id SERIAL PRIMARY KEY,
            "userId" TEXT UNIQUE NOT NULL,
            "selectedKitId" TEXT,
            "updatedAt" TIMESTAMPTZ DEFAULT NOW()
        );
    """)

    # NOTIFICATIONS TABLE (backend-persisted notifications)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS notifications (
            id SERIAL PRIMARY KEY,
            "userId" TEXT NOT NULL,
            "deviceId" TEXT NOT NULL,
            level TEXT NOT NULL,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            "isRead" BOOLEAN DEFAULT FALSE,
            "createdAt" TIMESTAMPTZ DEFAULT NOW()
        );
    """)
    
    cur.execute("""
        CREATE INDEX IF NOT EXISTS idx_notif_user ON notifications("userId");
    """)
    cur.execute("""
        CREATE INDEX IF NOT EXISTS idx_notif_time ON notifications("createdAt" DESC);
    """)

    # USER_KITS JUNCTION TABLE (many-to-many: user <-> kit)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS user_kits (
            "userId" TEXT NOT NULL,
            "kitId" TEXT NOT NULL REFERENCES kits(id) ON DELETE CASCADE,
            "addedAt" TIMESTAMPTZ DEFAULT NOW(),
            PRIMARY KEY ("userId", "kitId"),
            CHECK (LENGTH("userId") >= 8),
            CHECK (LENGTH("kitId") >= 5)
        );
    """)
    
    # Indexes for user_kits
    cur.execute("""
        CREATE INDEX IF NOT EXISTS idx_user_kits_user ON user_kits("userId");
    """)
    cur.execute("""
        CREATE INDEX IF NOT EXISTS idx_user_kits_kit ON user_kits("kitId");
    """)

    conn.commit()
    cur.close()
    release_connection(conn)

    logger.info("[DB] Migrations executed.")
