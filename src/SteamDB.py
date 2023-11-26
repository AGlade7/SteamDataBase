import psycopg2

conn = psycopg2.connect("host=localhost dbname=steamdb port=5432 user=postgres")
cur = conn.cursor()

makeDBPath = './Code/DB/makeDB.sql'
with open(makeDBPath, 'r') as sql_file:
    sql_query = sql_file.read()

cur.execute(sql_query)

conn.commit()

cur.close()
conn.close()