import os
import psycopg2
from contextlib import contextmanager
from dotenv import load_dotenv
from pathlib import Path

print(Path(__file__))
ENV_PATH = Path(__file__).resolve().parent.parent.joinpath(".env.example")
load_dotenv(ENV_PATH)

url = os.getenv("database_URL")
print(url)


@contextmanager
def get_db():
    try:
        conn = psycopg2.connect(url)
        print("connected with database")
        cursor = conn.cursor()
        makeDBPath = (
            Path(__file__)
            .resolve()
            .parent.parent.joinpath("create_database/makeDB.sql")
        )
        makeProcedurePath = (
            Path(__file__)
            .resolve()
            .parent.parent.joinpath("create_database/producure.sql")
        )
        with open(makeDBPath, "r") as sql_file:
            sql_query = sql_file.read()
        with open(makeProcedurePath, "r") as sql_file:
            sql_query2 = sql_file.read()
        cursor.execute(sql_query)
        cursor.execute(sql_query2)
        yield cursor
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        cursor.close()
        conn.close()


with get_db() as cursor:
    print("Inside the context")
