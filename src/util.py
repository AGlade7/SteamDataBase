from Connection import *
from pathlib import Path


DB_FOLDER = Path(__file__).resolve().parent.parent.joinpath("create_database")

def execute_script(script_file: str):
    try:
        with open(DB_FOLDER.joinpath(script_file), "r") as file:
            sql_script = file.read()
            with get_db() as db:
                db.execute(sql_script)
    except Exception as e:
        print(f"Error executing {script_file}: {e}")

def create_db():
    execute_script("makeDB.sql")


if __name__ == "__main__":
    # create_db()
