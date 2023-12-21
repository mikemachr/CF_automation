import psycopg2
import pandas as pd
from decouple import config




db_name = config('DB_NAME')
db_host = config('DB_HOST')
db_user = config('DB_USER')
db_password = config('DB_PASSWORD')

conn = psycopg2.connect(database=db_name, user=db_user, password=db_password, host=db_host)


query_file_path = 'query.sql'

# Read the SQL query from the file
with open(query_file_path, 'r') as query_file:
    sql_query = query_file.read()
# Use pandas to read the query result into a DataFrame
df = pd.read_sql_query(sql_query, conn)

# Close the database connection
conn.close()
df['late_for_pickup'] = round(df['late_for_pickup'])
df = df.drop('meal_id',axis=1)
df.loc[df['coast']=='EC'].to_csv('EC_post_shift.csv',index=False)
df.loc[df['coast']=='WC'].to_csv('WC_post_shift.csv',index=False)
