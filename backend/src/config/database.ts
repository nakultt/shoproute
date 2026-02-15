import { Pool } from "pg";
import dotenv from "dotenv";

dotenv.config();

const isProduction = process.env.NODE_ENV === "production";

// Prioritize specific connection strings:
// 1. DATABASE_URL (Render sets this automatically)
// 2. DATABASE_URL_PROD (Explicit prod config)
// 3. DATABASE_URL_DEV (Explicit dev config)
const connectionString =
  process.env.DATABASE_URL ||
  (isProduction ? process.env.DATABASE_URL_PROD : process.env.DATABASE_URL_DEV);

const poolConfig = connectionString
  ? {
      connectionString,
      ssl:
        isProduction || connectionString.includes("render.com")
          ? {
              rejectUnauthorized: false,
            }
          : undefined,
    }
  : {
      host: process.env.DB_HOST || "localhost",
      port: parseInt(process.env.DB_PORT || "5432"),
      database: process.env.DB_NAME || "shoproute",
      user: process.env.DB_USER || "postgres",
      password: process.env.DB_PASSWORD,
    };

const pool = new Pool({
  ...poolConfig,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test database connection
pool.on("connect", () => {
  console.log("✅ Connected to PostgreSQL database");
});

pool.on("error", (err) => {
  console.error("❌ Unexpected error on idle client", err);
  process.exit(-1);
});

export const query = async (text: string, params?: any[]) => {
  const start = Date.now();
  const res = await pool.query(text, params);
  const duration = Date.now() - start;

  if (process.env.NODE_ENV === "development") {
    console.log("Executed query", {
      text: text.substring(0, 50),
      duration,
      rows: res.rowCount,
    });
  }

  return res;
};

export const getClient = async () => {
  const client = await pool.connect();
  return client;
};

export default pool;
