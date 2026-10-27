# Blocks until Backend has created public.tenants (see Dockerfile).
import os, time
import psycopg2

for i in range(10**6):
    try:
        with psycopg2.connect(host=os.environ["pg_host"], port=os.environ.get("pg_port", 5432),
                              dbname=os.environ["pg_dbname"], user=os.environ["pg_user"],
                              password=os.environ["pg_password"], connect_timeout=5) as c, c.cursor() as cur:
            cur.execute("SELECT to_regclass('public.tenants')")
            if cur.fetchone()[0]:
                break
            err = "public.tenants not created yet"
    except psycopg2.Error as e:
        err = str(e).strip()
    if i % 6 == 0:
        print(f"waiting for the Backend to create the schema: {err}", flush=True)
    time.sleep(5)
